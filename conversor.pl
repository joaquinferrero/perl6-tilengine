#!/usr/bin/env perl -s
#
# Conversor de la API desde C++ a Perl 6 (escrito en Perl 5)
# Joaquín Ferrero
# 
# Primera versión: 23/02/2017
# Segunda versión: 02/03/2017
#
use v5.24;

# usar cpp para el preprocesado
# cpp -C -D_LIB ../../lib/Tilengine.h
#

__END__
use feature qw'signatures';
use strict;
use warnings;
no warnings "experimental::signatures";
use experimental 'switch';
use autodie;

use Data::Dumper; # XXX

#- Variables -----------------------------------------------------------------------------------------------------------

my %DEFINES;						# Constantes de define (y pasadas por línea de comandos)

my %tipos_predefinidos = (				# tipos predefinidos C++ a NativeCall
    'unsigned char'	=> 'uint8',
    'unsigned short'	=> 'uint16',
    'unsigned int'	=> 'uint32',
    'uint8_t'		=> 'uint8',
    'uint16_t'		=> 'uint16',
    'uint32_t'		=> 'uint32',
    'uint64_t'		=> 'uint64',
    'char'		=> 'int8',
    'short'		=> 'int16',
    'int'		=> 'int32',
    'int8_t'		=> 'int8',
    'int16_t'		=> 'int16',
    'int32_t'		=> 'int32',
    'int64_t'		=> 'int64',
    'float'		=> 'num32',
    'double'		=> 'num64',
    'void'		=> '',
);


#- Inicialización ------------------------------------------------------------------------------------------------------
our $h;							# Mensaje de ayuda
if ($h) {
    die "Uso: $0 -define=[NAME[,...]]\n";
}

our $define;						# Línea -define= con lista de constantes definidas
if ($define) {
    map { $DEFINES{$_} = 1 } split /[,]/, $define;
}


#- Patrones ------------------------------------------------------------------------------------------------------------


#- Procesado -----------------------------------------------------------------------------------------------------------
open my $FH, '<:crlf', '../../lib/Tilengine.h';
my @archivo_original = <$FH>;
close $FH;

my @archivo_preprocesado = preprocesador(@archivo_original);

say @archivo_preprocesado;


#- Subrutinas ----------------------------------------------------------------------------------------------------------
sub preprocesador(@original) {			# directivas del preprocesador
    my @procesado;

    while (@original) {

	my $linea = shift @original;
	chomp $linea;

	# dentro de un 'if'
	if (my($comando, $resto) = $linea =~ m{^\s*#(\w+)(?:\s+(.+))?}) {

	    given ($comando) {
		when (/^if(?:n?def)?$/) {
		    # Probar aquí la condición
		    if (testear_expresion($comando, $resto)) {
			# Si es cierta, mandamos preprocesar el resto
			# ERROR: esto no es correcto: un if se encuentra con un elif o else
			# solución: rutina para extraer la sección, de forma manual (al estilo del else de abajo).
			my @resto = preprocesador(@original);
			push @procesado, @resto;
			@original = ();			# acabamos
			next;
		    }
		    else {
			# si no, cambiamos $comando a 'else'
			# para que entre en el siguiente if
			$comando = 'else';
		    	continue;
		    }
		}
		when (/el(?:se|if)/) {
		    # sacar todas las líneas hasta el próximo endif
		    my $profundidad_if = 0;
		    while (@original) {
			my $linea = shift @original;

			# Contar las profundidades de if...endif internos
			if ($linea =~ /^\s*#if/) { $profundidad_if++ }
			elsif ($linea =~ /^\s*#endif/) { last if not $profundidad_if-- }
		    }
		    next;
		}
		when ('endif') {
		    next;
		}
		when ('define') {
		    my($nombre, $valor) = split " ", $resto, 2;
		    $DEFINES{$nombre} = $valor // '';
		    next;
		}
	    }
	}

	push @procesado, "$linea\n";
    }

    return @procesado;
}

sub testear_expresion ($comando, $expresion) {
    # tipos de comandos:
    # * if : la expresión es cierta
    # * ifdef : el identificador está definido
    # * ifndef: el identificador no está definido
    #
    # tipos de expresiones de defines
    # * un identificador: se prueba si está definido
    # * 'defined'+identificador: se prueba si está definido
    given ($comando) {
    	when ('ifndef') {
    	    return not testear_expresion('ifdef', $expresion);
	}
	when ('if') {
	    if ($expresion =~ /^\s*defined\s+(.+)/) {
	    	return testear_expresion('ifdef', $1);
	    }
	    else {
		say "ERROR: expresión desconocida: [$comando][$expresion]";
		return -1;
	    }
	}
	when ('ifdef') {
	    # Probar la definición
	    given ($expresion) {
		when (/^\(?(\w+)\)?$/) {		# es un simple identificador
		    return defined $DEFINES{$1};
		}
	    	default {
		    say "ERROR: expresión desconocida: [$comando][$expresion]";
		    return -1;
		}
	    }
	}
	default {
	    say "ERROR: expresión desconocida: [$comando][$expresion]";
	    return -1;
	}
    }
}
__END__

	# Comentario de una sola línea
	if (my($spc, $cmnt) = $linea =~ m{(\s*) [/][*] (.+) \s* [*][/] \s* $}x) {
	    next if $cmnt =~ /[@][{}]/;				# caso especial
	    $cmnt =~ s{^!<}{};					# caso especial
	    $linea = "$spc#$cmnt";
	    push @procesado, $linea;
	    next;
	}

	# Comentarios de varias líneas
	if (my $comentario = $linea =~ m{^ \s* [/][*]}x .. $linea =~ m{ [*][/] \s* $}x) {
	    $linea =~ s{\s*[*][/]$}{};				# fin de comentario
	    $linea =~ s{^\s*[*]\s*}{};				# quitar '*' iniciales
	    $linea =~ s{^\s*[/][*][*]?}{};			# quitar '/*?'
	    push @procesado, "$comentario # $linea";
	    next;
	}

my $re_nombre     = qr{ (?<nombre>\b \w+ \b) }x;
my $re_valor      = qr{ \s* = \s* \K (?<valor>[^,]+) }x;
my $re_comentario = qr{ \s* [/][*] \s* \K (?<comentario>.+) (?>\s* [*][/]) }x;

my $en_cmt = 'E0';
my %tipos_definidos;
my @cache;

my %defines;
my %constants;
my %structs;		# lista de estructuras conocidas


say "use v6;";
say "unit class Tilengine:ver<117.2.27>:auth<Joaquin Ferrero (jferrero\@gmail.com)>;";
say "";
say "use NativeCall;";
say "";

while (<$FH_API>) {
    chomp;

    # líneas vacías
    if (/^ \s* $/x  and $en_cmt =~ /E0/) {
	say "";
	next;
    }

    # líneas de defines ifdef/ifndef/else/elif/endif
    if (/^ \s* [#] (?:if|el|endif)/x) {
    	next;
    }

    # líneas superfluas
    if (/^(?:extern "C"[{]|[}])$/) {
    	next;
    }

    # línas de defines
    if (my($nombre, $valor) = /^ \s* [#] \s* define \s+ (\S+) \s* (.*)/x) {
	$valor = "''" if not defined($valor)  or  0 == length $valor ;
	if (exists $tipos_predefinidos{$valor}) {
	    say "#" . parsea_define($nombre, $valor);
	}
	else {
	    $tipos_predefinidos{$valor} = $nombre;
	    say parsea_define($nombre, $valor);
	}
    	next;
    }

    # líneas de typedef struct de una línea
    if (m/^typedef struct\s+(?<tipo>\S+)\s+(?<nuevotipo>\w+);(?:\s*$re_comentario)?/) {
	my $tipo = $+{tipo};
	my $nuevotipo = $+{nuevotipo};
	my $es_puntero;
	if ('*' eq substr $tipo, -1, 1) {
	    $tipo = substr $tipo, 0, -1;
	    $es_puntero = 1;
	}
	if (not $tipos_predefinidos{$tipo}) {
	    warn "TIPO NO DEFINIDO: $tipo. Se cambia a Pointer";
	    $tipo = 'Pointer';
	    $tipos_predefinidos{$nuevotipo} = $tipo;
	}
	#if ($es_puntero) {
	#    $tipo = "Pointer[$tipo]";
	#}
	say "class $nuevotipo is $tipo is export { }";
    	next;
    }

    # líneas de typedef de una línea
    if (m{^ typedef \s+ (?<tipo>.+?) \s+ (?<nuevotipo>\w+); (?: (?<sp>\s*) [/] [*] (?<comentario>.+?) [*] [/])? }x) {
    	my $cmt = $+{comentario} // '';
    	my($tipo, $nuevotipo) = @+{qw(tipo nuevotipo)};
    	$cmt = "$+{sp}# $cmt" if $cmt;
	#say "TYPEDEF: $tipo $nuevotipo $cmt";
	# cambiar los tipos
	$tipo = $tipos_predefinidos{$tipo} // $tipo;
	$nuevotipo = "constant $nuevotipo";
	if ($constants{$nuevotipo} or $nuevotipo =~ /(?:bool|true|false)/) {
	    $nuevotipo = "#$nuevotipo";
	}
	say "$nuevotipo = $tipo;$cmt";
	$tipos_definidos{$nuevotipo} = $tipo;
	$constants{$nuevotipo} = $tipo;
	next;
    }

    # líneas de typedef enum
    if (/^ typedef [ ] enum/x .. /^ (\w+) ; $/x) {
    	my $nombre = $1;
    	next if /^ (?:typedef [ ] enum|[{}])/x;
	if (defined $nombre) {
	    say "enum $nombre (";
	    my $cnt = 0;
	    for my $cache (@cache) {
		$cache =~ m{$re_nombre (?:$re_valor)? (?:,? $re_comentario)?}x;
		my $nombre = $+{nombre} // "ERROR: [$cache]";
		my $valor = $+{valor} // $cnt;
		$valor = parsea_expr($valor);
		my $cmt = $+{comentario} // '';
		$cmt = "\t# $cmt" if $cmt;
		say "\t$nombre => $valor,\t\t$cmt";
		$cnt++;
	    }
	    say ");";
	    @cache = ();
	}
	else {
	    push @cache, $_;
	}
	next;
    }

    # líneas de typedef struct
    if (/^typedef [ ] struct/x .. /^ (\w+) ; $/x) {
    	my $nombre = $1;
    	next if /^ (?:typedef [ ] struct|[{}])/x;
    	if (defined $nombre) {
    	    $structs{$nombre} = 1;
	    say "class $nombre is repr('CStruct') is export  {";
	    for my $cache (@cache) {
	    	$cache =~ m{ (?<tipo>\w+) \s+ (?<nombre>\w+) ; (?:$re_comentario)?}x;
	    	my($tipo, $nombre, $comentario) = @+{qw(tipo nombre comentario)};
		$tipo = $tipos_predefinidos{$tipo} // $tipo;
		$comentario = "\t\t# $+{comentario}" if $+{comentario};
		say "\thas $tipo\t\$.$nombre\tis rw;$comentario";
	    }
	    say "}";
	    @cache = ();
	}
	else {
	    push @cache, $_;
	}
    	next;
    }

    # comentarios de una línea
    if (my($cmt) = m{^ \s* $re_comentario}x) {
    	next if $cmt =~ /\@[{}]/;
        say "# $cmt";
    	next;
    }

    # comentarios de varias líneas
    if (my $cmt = m{ ^ \s* [/] [*] }x .. m{ [*] [/] $ }x) {
        s{^ \s* [/] [*] \s* }{}x;
        s{  \s* [*] [/] $   }{}x;
        s{^ \s* [*] \s*     }{}x;
        say "# $_";
        $en_cmt = $cmt;
    	next;
    }

    # líneas con declaración de funciones
    if (/^TLNAPI\s+(?<retorno>const \w+ [*]|\w+[*]?\s+)(?<function>\w+) ?\((?<args>.+?)\);/) {
	#say "[$+{function}]($+{args})=>[$+{retorno}]";
    	my $retorno = $+{retorno};
    	my $function = $+{function};
    	my $args = $+{args};
    	$retorno =~ s/\s+$//;
    	my $funcion_ref = [ $function, $args, $retorno ];

	# transformar los argumentos a tipos estándar
	#my $args = $funcion_ref->[1];

	# crear los dos tipos de argumentos
	# 1. Argumentos solo tipos
	my @args_solo_tipos;
	my @args_solo_vars;
	my @args_tipos_vars;
	for my $arg (split /, ?/, $args) {
	    #say $arg;
	    my($tipo,$var) = $arg =~ /^(void(?:.+)?|.+?)(?: (\w+))?$/;
	    #if (not defined $var) {
	    #    $var = $tipo;
	    #    $var =~ s/TLN_/\$/;
	    #}
	    $tipo = cambia_tipos($tipo);
	    push @args_solo_tipos,  $tipo;
	    if ($var) {
		#say "$tipo|$var";
		push @args_solo_vars,  "\$$var";
		push @args_tipos_vars, "$tipo \$$var";
	    }
	    else {
		#say "$tipo";
		push @args_tipos_vars, $tipo;
	    }

	}
	my $solo_tipos = join ', ' => @args_solo_tipos;
	my $solo_vars  = join ', ' => @args_solo_vars;
	my $tipos_var  = join ', ' => @args_tipos_vars;

	# 2. Argumentos tipos y parámetros

	# valor de retorno
	my $returns = cambia_tipos($funcion_ref->[2]);
	$retorno = '';
	if ($returns and $returns ne 'void') {
	    $retorno = " returns $returns";
	}

	# crear nombre de método
	my $method = $funcion_ref->[0] =~ s/^TLN_//r;

	say "my sub $funcion_ref->[0]($solo_tipos)$retorno is native('Tilengine') { * }";
	say "method $method($tipos_var) { $funcion_ref->[0]($solo_vars) }";
	say "";

	# my sub $funcion_ref->[0](int32, int32, int32, int32, int32) returns bool is native('Tilengine') { * };
	# method Init (int32 $hres, int32 $vres, int $numlayers, int $numsprites, int $numanimations) { TLN_Init($hres, $vres, $numlayers, $numsprites, $numanimations) };

    	next;
    }

    # Si llegamos aquí, nos hemos dejado algo
    say "ERROR: [$_]";
}

sub cambia_tipos {
    my $org = shift;

    while (my($tipo, $nuevotipo) = each %tipos_predefinidos) {
	if ($tipo =~ /BYTE/) {
	    warn "Tipo: [$tipo] Nuevo: [$nuevotipo] Org: [$org]\n";
	}
	$org =~ s/\b$tipo[*]\b/Pointer/g;
	$org =~ s/\b$tipo\b/$nuevotipo/g;
	#if ($tipo =~ /const/) {
	#    say "Tipo: [$tipo] Nuevo: [$nuevotipo] Org: [$org]";
	#}
    }
    #$org =~ s/int/int32/g;
    #$org =~ s/BYTE/uint8/g;
    #$org =~ s/DWORD/int32/g;
    #$org =~ s/const char ?[*]/Pointer/g;

    return $org;
}

sub parsea_expr ($expr) {
    $expr =~ s/>>/+>/g;
    $expr =~ s/<</+</g;
    $expr =~ s/[|]/+|/g;
    return $expr;
}

sub parsea_define($nombre, $valor) {
    my $define_funcion = 0;
    if ($nombre =~ /^ (.+?) \( (.+?) \)/x) {
	$nombre = "sub $1(\$$2) {";
	$define_funcion = $2;
    }
    else {
    	$nombre = "constant $nombre =";
    }
    $valor = parsea_expr($valor);
    if ($define_funcion) {
    	$valor = cambia_tipos($valor);
	$valor =~ s/\b$define_funcion\b/\$$define_funcion/g;
	$valor .= " }";
    }
    else {
    	$valor .= ';';
    }

    $nombre = "#$nombre" if $nombre =~ /\b (?:bool|true|false) \b/x;

    return "$nombre $valor";
}

__END__

my @funciones;
my($y, $m, $d) = (localtime)[5, 4, 3];
$m++;


print $SALIDA "}\n";

close $SALIDA;

