// Unity 기본 PBR Shader + Dissolve Shader 구현

Shader "Custom/PBR_Dissolve"
{
    Properties
    {
        // 기본 PBR Shader 프로퍼티
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0

        // Dissolve Shader 프로퍼티
        _NoiseTex("Noise Texture", 2D) = "white" {}
        _EdgeColor1("Edge colour 1", Color) = (1.0, 1.0, 1.0, 1.0)
        _EdgeColor2("Edge colour 2", Color) = (1.0, 1.0, 1.0, 1.0)
        _Level("Dissolution level", Range(0.0, 1.0)) = 0.1
        _Edges("Edge width", Range(0.0, 1.0)) = 0.1
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType" = "Transparent" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows

        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
        };

        // 기본 PBR Shader 프로퍼티
        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        // Dissolve Shader 프로퍼티
        sampler2D _NoiseTex;
        float4 _EdgeColor1;
        float4 _EdgeColor2;
        float _Level;
        float _Edges;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
        // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;

            // Dissolve shader 프로퍼티 적용 - PerlinNoiseTexGenerator에서 생성한 Texture에서 기본 정점 UV값을 통해 알파 적용할 값을 가져온다
            float cutout = tex2D(_NoiseTex, IN.uv_MainTex).r;

            // _Level보다 값이 낮으면 아예 그리지 않는다.
            if (cutout < _Level)
                discard;

            // cutout이 BaseMap의 Alpha 값보다 낮고 잘라낼 _Level보다 _Edges보다는 작은 경우
            // 펄린 노이즈 특성상 그라데이션 되는 정도에 따라 경계선 부분을 지정한 _EdgeColor1 에서 _EdgeColor2 까지 선형 보간하여 색상을 결정
            // (사라지는 경계선 부분 구현)
            if (cutout < c.a && cutout < _Level + _Edges)
                c = lerp(_EdgeColor1, _EdgeColor2, (cutout - _Level) / _Edges);

            // 출력 Surface에 Albedo 및 Alpha 세팅, 나머지는 Standard PBR Shader를 그대로 활용한다.
            o.Albedo = c.rgb;
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
