# perl6-tilengine

Estas fuentes forman parte de una presentación sobre el uso de la biblioteca NativeCall de Perl6.

Se usa como ejemplo el acceso a la biblioteca Tilengine, un motor de animación 2D con efectos 3D.

http://www.tilengine.org/

La intención es terminar con un binding para Perl6, en forma de módulo.

Todavía están sin perfilar ni terminar pero... ¡la gente insiste en verlos! Pues aquí, para pública vergüenza.

Para hacerlos funcionar,

1. hay que tener instalada la distribución de Tilengine: http://www.tilengine.org/#download

2. descomprimir la distribución, y crear un directorio perl/ dentro de la carpeta bindings/

3. copiar ahí las fuentes de este repositorio

4. cambiar el directorio actual a la carpeta de ejemplos bin/

5. ejecutar con perl6 ../bindings/perl/programa.p6


Programas disponibles:

* scaling.p6 - ejemplo
* platforme.p6 - ejemplo de movimiento de fondos y procesamiento de la pantalla línea a línea
* SuperMarioClone.p6 - ejemplo sencillo con recursos de Mario Bros
* SuperMarioClone_1.p6 - lo mismo, pero con efectos de salto, desplazamiento de fondos, detección de teselas, etc.
* Tilengine0.pm6 y Tilengine1.pm6 - versiones beta de la biblioteca
* Tilengine.net.pm6 - biblioteca generada por conversor.pl
* conversor.pl - Programa en Perl 5 para intentar convertir la biblioteca .h a .pm6


