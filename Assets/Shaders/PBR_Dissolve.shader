// Unity �⺻ PBR Shader + Dissolve Shader ����

Shader "Custom/PBR_Dissolve"
{
    Properties
    {
        // �⺻ PBR Shader ������Ƽ
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0

        // Dissolve Shader ������Ƽ
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

        // �⺻ PBR Shader ������Ƽ
        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        // Dissolve Shader ������Ƽ
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

            // Dissolve shader ������Ƽ ���� - PerlinNoiseTexGenerator���� ������ Texture���� �⺻ ���� UV���� ���� ���� ������ ���� �����´�
            float cutout = tex2D(_NoiseTex, IN.uv_MainTex).r;

            // _Level���� ���� ������ �ƿ� �׸��� �ʴ´�.
            if (cutout < _Level)
                discard;

            // cutout�� BaseMap�� Alpha ������ ���� �߶� _Level���� _Edges���ٴ� ���� ���
            // �޸� ������ Ư���� �׶��̼� �Ǵ� ������ ���� ��輱 �κ��� ������ _EdgeColor1 ���� _EdgeColor2 ���� ���� �����Ͽ� ������ ����
            // (������� ��輱 �κ� ����)
            if (cutout < c.a && cutout < _Level + _Edges)
                c = lerp(_EdgeColor1, _EdgeColor2, (cutout - _Level) / _Edges);

            // ��� Surface�� Albedo �� Alpha ����, �������� Standard PBR Shader�� �״�� Ȱ���Ѵ�.
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
