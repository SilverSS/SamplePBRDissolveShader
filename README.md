# SamplePBRDissolveShader

※ Shader code 주석을 달기 용이하도록 HLSL로 작성하고 URP가 적용된 코드는 복잡한 구조를 띌 수 밖에 없어 Standard PBR 기준으로 작성

※ Dissolve Shader

※ CameraDepthTexture와 GrabTexture(RenderTexture)을 통해
   Fresnel효과+Distortion효과를 적용한 배리어 효과
   
※ 인접한 면을 기준으로 Fresnel을 계산하여 오브젝트에 상호작용하는 듯한 이펙트 처리

※ Unity3D 2022.3.22f 버전으로 작업
