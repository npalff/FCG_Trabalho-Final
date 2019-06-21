#version 330 core

// Atributos de fragmentos recebidos como entrada ("in") pelo Fragment Shader.
// Neste exemplo, este atributo foi gerado pelo rasterizador como a
// interpola��o da posi��o global e a normal de cada v�rtice, definidas em
// "shader_vertex.glsl" e "main.cpp".
in vec4 position_world;
in vec4 normal;

// Posi��o do v�rtice atual no sistema de coordenadas local do modelo.
in vec4 position_model;

// Coordenadas de textura obtidas do arquivo OBJ (se existirem!)
in vec2 texcoords;

// Cor interpolada dos v�rtices do tri�ngulo no qual est� o ponto
in vec3 cor_v;

// Kds lidos do mtl
//in vec4 materialKd;

// Matrizes computadas no c�digo C++ e enviadas para a GPU
uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

// Identificador que define qual objeto est� sendo desenhado no momento
#define SPHERE 0
#define TREE   1
#define PLANE  2
#define TRUCK  3
#define TIRE   4
#define TIRE2  5
#define TROFEU 6
#define TROFEU2 7
#define CONE_B 8
#define CONE_L 9
uniform int object_id;

// Par�metros da axis-aligned bounding box (AABB) do modelo
uniform vec4 bbox_min;
uniform vec4 bbox_max;

// Vari�veis para acesso das imagens de textura
uniform sampler2D TextureImage0;
uniform sampler2D TextureImage1;
uniform sampler2D TextureImage2;

// O valor de sa�da ("out") de um Fragment Shader � a cor final do fragmento.
out vec3 color;

// Constantes
#define M_PI   3.14159265358979323846
#define M_PI_2 1.57079632679489661923

void main()
{
    // Obtemos a posi��o da c�mera utilizando a inversa da matriz que define o
    // sistema de coordenadas da c�mera.
    vec4 origin = vec4(0.0, 0.0, 0.0, 1.0);
    vec4 camera_position = inverse(view) * origin;

    // O fragmento atual � coberto por um ponto que percente � superf�cie de um
    // dos objetos virtuais da cena. Este ponto, p, possui uma posi��o no
    // sistema de coordenadas global (World coordinates). Esta posi��o � obtida
    // atrav�s da interpola��o, feita pelo rasterizador, da posi��o de cada
    // v�rtice.
    vec4 p = position_world;

        // Normal do fragmento atual, interpolada pelo rasterizador a partir das
        // normais de cada v�rtice.
        vec4 n = normalize(normal);

    // Vetor que define o sentido da fonte de luz em rela��o ao ponto atual.
    vec4 l = normalize(vec4(1.0,1.0,0.0,0.0));

    // Vetor que define o sentido da c�mera em rela��o ao ponto atual.
    vec4 v = normalize(camera_position - p);

    // Vetor que define o sentido da reflex�o especular ideal.
    vec4 r = -l + 2*n*(dot(n, l));


    // Coordenadas de textura U e V
    float U = 0.0;
    float V = 0.0;

    vec3 Kd;  // Reflet�ncia difusa
    vec3 Ks = vec3(0.0f, 0.0f, 0.0f); // Reflet�ncia especular
    float q = 1;  // Expoente especular para o modelo de ilumina��o de Phong

    if ( object_id == SPHERE )
    {
        // PREENCHA AQUI as coordenadas de textura da esfera, computadas com
        // proje��o esf�rica EM COORDENADAS DO MODELO. Utilize como refer�ncia
        // o slide 144 do documento "Aula_20_e_21_Mapeamento_de_Texturas.pdf".
        // A esfera que define a proje��o deve estar centrada na posi��o
        // "bbox_center" definida abaixo.

        // Voc� deve utilizar:
        //   fun��o 'length( )' : comprimento Euclidiano de um vetor
        //   fun��o 'atan( , )' : arcotangente. Veja https://en.wikipedia.org/wiki/Atan2.
        //   fun��o 'asin( )'   : seno inverso.
        //   constante M_PI
        //   vari�vel position_model

        vec4 bbox_center = (bbox_min + bbox_max) / 2.0;

        float rho = 1; // Raio
        vec4 pe = bbox_center + rho * normalize(position_model - bbox_center); // Ponto na esfera (p')
        vec4 p = pe - bbox_center; // Vetor do centro da esfera passando pelo ponto no objeto at� o ponto na esfera

        float theta = atan(p.x, p.z);
        float phi = asin(p.y/rho);

        U = (theta + M_PI) / (2*M_PI);
        V = (phi + M_PI_2) / M_PI;

    }
//    else if ( object_id == BUNNY )
//    {
//        // PREENCHA AQUI as coordenadas de textura do coelho, computadas com
//        // proje��o planar XY em COORDENADAS DO MODELO. Utilize como refer�ncia
//        // o slide 111 do documento "Aula_20_e_21_Mapeamento_de_Texturas.pdf",
//        // e tamb�m use as vari�veis min*/max* definidas abaixo para normalizar
//        // as coordenadas de textura U e V dentro do intervalo [0,1]. Para
//        // tanto, veja por exemplo o mapeamento da vari�vel 'p_v' utilizando
//        // 'h' no slide 154 do documento "Aula_20_e_21_Mapeamento_de_Texturas.pdf".
//        // Veja tamb�m a Quest�o 4 do Question�rio 4 no Moodle.
//
//        float minx = bbox_min.x;
//        float maxx = bbox_max.x;
//
//        float miny = bbox_min.y;
//        float maxy = bbox_max.y;
//
//        float minz = bbox_min.z;
//        float maxz = bbox_max.z;
//
//        U = position_model.x;
//        V = position_model.y;
//
//        U = (U - minx) / (maxx - minx);
//        V = (V - miny) / (maxy - miny);
//    }
    else if ( object_id == PLANE )
    {
        // Coordenadas de textura do plano, obtidas do arquivo OBJ.
        U = texcoords.x;
        V = texcoords.y;

        // Obtemos a reflet�ncia difusa a partir da leitura da imagem TextureImage0
        Kd = texture(TextureImage0, vec2(U,V)).rgb;
    }
    else if ( object_id == TRUCK )
    {
        U = texcoords.x;
        V = texcoords.y;
        Kd = texture(TextureImage1, vec2(U,V)).rgb;
    }
    else if ( object_id == TREE )
    {
        U = texcoords.x;
        V = texcoords.y;
        Kd = texture(TextureImage2, vec2(U,V)).rgb;
    }
    else if ( object_id == TIRE )
    {
        Kd = vec3(1, 0.0, 0.0);
    }
    else if ( object_id == TIRE2 )
    {
        Kd = vec3(0.9, 0.9, 0.9);
    }
    else if ( object_id == TROFEU )
    {
        Kd = vec3(1.0, 0.843, 0.0);
        Ks = vec3(0.8,0.8,0.8);
        q = 10;
    }
    else if ( object_id == CONE_B )
    {
        Kd = vec3(0.9, 0.9, 0.9);
        l = n + vec4(0.0, 1.0, 0.0, 0.0); // Altera��o da dire��o da luz para ver melhor o cone
    }
    else if ( object_id == CONE_L )
    {
        Kd = vec3(1.0, 0.333, 0.0);
        l = n + vec4(0.0, 1.0, 0.0, 0.0); // Altera��o da dire��o da luz para ver melhor o cone
    }

    // Equa��o de Ilumina��o
    float lambert = max(0,dot(n,l));
    float phong = pow(max(0.0, dot(r, v)), q);

    color = Kd * (lambert + 0.01) + Ks * phong;

    if ( object_id == TROFEU2 )
    {
        color = cor_v;
    }

    // Cor final com corre��o gamma, considerando monitor sRGB.
    // Veja https://en.wikipedia.org/w/index.php?title=Gamma_correction&oldid=751281772#Windows.2C_Mac.2C_sRGB_and_TV.2Fvideo_standard_gammas
    color = pow(color, vec3(1.0,1.0,1.0)/2.2);
}

