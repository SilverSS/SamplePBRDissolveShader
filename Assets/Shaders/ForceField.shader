Shader "Unlit/ForceField"
{
	Properties
	{
		_MainColor("MainColor", Color) = (1,1,1,1)
		_MainTex ("Texture", 2D) = "white" {}
		_Fresnel("Fresnel Intensity", Range(0,200)) = 3.0
		_FresnelWidth("Fresnel Width", Range(0,2)) = 3.0
		_Distort("Distort", Range(0, 100)) = 1.0
		_IntersectionThreshold("Highlight of intersection threshold", range(0,1)) = .1 //Max difference for intersections
		_ScrollSpeedU("Scroll U Speed",float) = 2
		_ScrollSpeedV("Scroll V Speed",float) = 0
		//[ToggleOff]_CullOff("Cull Front Side Intersection",float) = 1
	}
	SubShader
	{ 
		Tags{ "Queue" = "Overlay" "IgnoreProjector" = "True" "RenderType" = "Transparent" }

		GrabPass{ "_GrabTexture" }
		Pass
		{
			Lighting Off ZWrite On
			Blend SrcAlpha OneMinusSrcAlpha
			Cull Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			struct appdata
			{
				fixed4 vertex : POSITION;
				fixed4 normal: NORMAL;
				fixed3 uv : TEXCOORD0;
			};

			struct v2f
			{
				fixed2 uv : TEXCOORD0;
				fixed4 vertex : SV_POSITION;
				fixed3 rimColor :TEXCOORD1;
				fixed4 screenPos: TEXCOORD2;
			};

			// _CameraDepthTexture : 현재 Shader를 사용하는 렌더러를 제외하고 렌더링 되는 카메라 기준 Depth기록 텍스쳐 (Unity Shader 예약)
			// _GrabTexture : 현재 Shader를 사용하는 렌더러를 제외하고 렌더링 되는 렌더 텍스쳐 (Unity Shader 예약)
			sampler2D _MainTex, _CameraDepthTexture, _GrabTexture;

			fixed4 _MainTex_ST,_MainColor,_GrabTexture_ST, _GrabTexture_TexelSize;
			fixed _Fresnel, _FresnelWidth, _Distort, _IntersectionThreshold, _ScrollSpeedU, _ScrollSpeedV;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				// 정점 UV 스크롤
				o.uv.x += _Time * _ScrollSpeedU;
				o.uv.y += _Time * _ScrollSpeedV;

				// ---------- fresnel 효과 적용 ------------ //
				// 카메라가 바라본 방향 벡터
				fixed3 viewDir = normalize(ObjSpaceViewDir(v.vertex));

				// 정점 노멀 & View Vector 내적하여 rimColor 계수 계산 (전형적인 rimColor 계산 공식 사용)
				fixed dotProduct = 1 - saturate(dot(v.normal, viewDir));
				o.rimColor = smoothstep(1 - _FresnelWidth, 1.0, dotProduct) * .5f;

				// 화면 좌표계 기준 UV
				o.screenPos = ComputeScreenPos(o.vertex);

				// 카메라로 부터 해당 정점간 거리(Depth)
				COMPUTE_EYEDEPTH(o.screenPos.z);//eye space depth of the vertex 
				return o;
			}
			
			fixed4 frag (v2f i,fixed face : VFACE) : SV_Target
			{
				// 면 중첩 계산, _CameraDepthTexture에 기록된 Depth와 정점 Shader에서 계산되어 넘어온 Depth를 비교 하여 중첩 적용 거리 계산
				fixed intersect = saturate((abs(LinearEyeDepth(tex2Dproj(_CameraDepthTexture,i.screenPos).r) - i.screenPos.z)) / _IntersectionThreshold);

				// 왜곡 및 배리어 질감을 나타낼 텍스쳐 텍셀 color.rgb
				fixed3 main = tex2D(_MainTex, i.uv);

				//distortion, 노멀맵으로 굴절 방향을 표현하는 것이 일반적이지만 예제에서는 Grayscale과 다름 없는 텍스쳐 사용, 현재 사용된 헥사곤 텍스쳐로 적용되는값은 (0,0) (1,1) 두가지 뿐, 왜곡 방향은 계산식 부호로 조절 가능
				i.screenPos.xy += (main.rg * 2 - 1) * _Distort * _GrabTexture_TexelSize.xy;

				// 위에서 계산된 방향의 픽셀을 이전에 렌더된 렌더텍스쳐에서 가져온다.
				fixed3 distortColor = tex2Dproj(_GrabTexture, i.screenPos);

				// MainColor 에서 설정한 Alpha로 블렌딩 처리
				distortColor *= _MainColor * _MainColor.a + 1;

				// 중첩 거리에 따른 rim 색상 처리
				i.rimColor *= intersect * clamp(0,1,face);

				// 메인 재질 컬러에 Fresnel 프로퍼티 색상을 림 컬러와 곱해준다
				main *= _MainColor * pow(_Fresnel,i.rimColor) ;
				
				// 계산된 rimColor.r 을 이용해 distort color & fresnel color 선형보간 
				main = lerp(distortColor, main, i.rimColor.r);

				// (1 - intersect) : 중첩 면에 가까울수록 intersect는 0에 가까운 값을 가진다. 중첩 면에 가까운 부분에 색이 들어가야 하기 때문에 1 - intersect를 색상에 더해준다. 
				// face는 현재 면이 카메라를 향하는지의 여부 (0보다 크먼 카메라를 향하는 면)
				main += (1 - intersect) * (face > 0 ? .03:.3) * _MainColor * _Fresnel;

				// Alpha값을 0.9로 하는 이유 : 1.0으로 하게 되면 모두 바깥 면만이 보여지게 된다. 바깥쪽 색상을 계산한 색상 값에 근사하게 표현하면서 안쪽면에 나타난 중첩 Fresnel 효과를 같이 보여주기 위해 시행 착오 끝에 0.9의값을 사용, 수치는 적절히 조절 하여 사용하도록 프로퍼티로 설정해도 무방
				return fixed4(main,.9);
			}
			ENDCG
		}
	}
}
