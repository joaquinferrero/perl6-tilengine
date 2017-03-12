#!/usr/bin/env perl
#
# Conversor de la API desde C++ a Perl 6 (escrito en Perl 5)
# Joaquín Ferrero
# 
# v1.0: 23/02/2017
# v2.0: 02/03/2017
# v3.0: 06/03/2017
# v4.0: 09/03/2017
#
use v5.14;
use strict;
use warnings;
use feature qw'signatures';
no warnings "experimental::signatures";
use autodie;
use FindBin qw($Bin);


#- Configuración -------------------------------------------------------------------------------------------------------
my $FILE_LIB	     = 'Tilengine.h';
my @PATH_TILENGINE_H = (
    "$Bin/../../lib/$FILE_LIB",
    "/usr/include/$FILE_LIB",
);


#- Constantes ----------------------------------------------------------------------------------------------------------
my $TILENGINE_H;
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

#- Patrones ------------------------------------------------------------------------------------------------------------
my $re_nombre     = qr{ (?<nombre>\b \w+ \b) }x;
my $re_valor      = qr{ \s* = \s* (?<valor>.+?) }x;
my $re_comentario = qr{ (?<comentario>\# .+) }x;


#- Proceso -------------------------------------------------------------------------------------------------------------
#filtrar_biblioteca();					# filtrar los finales de línea del archivo
preprocesar_biblioteca();				# pasar la biblioteca por el preprocesador
limpiar();						# procesar comentarios y líneas dobles vacías
typedef_tipos();					# definición de nuevos tipos
typedef_enum();						# líneas typedef enum de una sola línea
typedef_struct_linea();					# líneas typedef struct de una sola línea
typedef_struct();					# líneas de typedef struct
pone_punteros();					# cambia 'struct *' a Pointer y 'const char *' a Str
funciones();						# líneas con declaración de funciones

# preámbulo
my $resultado = '';
$resultado .= "use v6;";
$resultado .= "unit class Tilengine:ver<2017.03.06>:auth<Joaquin Ferrero (jferrero\@gmail.com)>;";
$resultado .= "";
$resultado .= "use NativeCall;";
$resultado .= "";
$resultado .= $TILENGINE_H;
$TILENGINE_H = $resultado;

# salida
say $TILENGINE_H;

#- Subrutinas ----------------------------------------------------------------------------------------------------------
sub filtrar_biblioteca {				#Filtrar finales de línea 
    my $convertido;

    for my $path (@PATH_TILENGINE_H) {
        if (-f $path) {
    	local $/;
    	open my $FHL, '<:crlf', $path;
    	open my $FHE, '>', "$Bin/$FILE_LIB";
    	print   $FHE scalar <$FHL>;
    	close   $FHL;
    	close   $FHE;
    	$convertido = 'si';
    	last;
        }
    }
    if (not $convertido) {
        die "ERROR: No encuento la biblioteca [$FILE_LIB]\n";
    }
}
sub preprocesar_biblioteca {				# preprocesar el archivo
    for my $path (@PATH_TILENGINE_H) {
        if (-f $path) {
	    local $/;

	    open my $TLH, '<:crlf', $path;		# Limpieza de los finales de línea
	    my $tmp = <$TLH>;
	    close $TLH;

	    open  $TLH, '>', $FILE_LIB;
	    print $TLH $tmp;
	    close $TLH;

	    open  my $FH, "cpp -C -D_LIB $FILE_LIB |";	# preprocesamiento usando el comando cpp
	    $TILENGINE_H = <$FH>;
	    close $FH;

	    return;
	}
    }

    die "ERROR: No encuentro la biblioteca en las rutas indicadas\n";
}
sub limpiar {						# procesar comentarios y líneas dobles vacías
    my $coment_en_linea_anterior;
    my $resultado;

    for my $linea (split /\n/, $TILENGINE_H) {
	next if $linea =~ /^# 1 "$FILE_LIB"/ ... $linea =~ /^# 1 "$FILE_LIB"/;	# Preámbulo
	next if $linea =~ /^# \d+ "$FILE_LIB"/;
	next if $linea =~ /^\s*$/ and $coment_en_linea_anterior;	# Líneas vacías
	$coment_en_linea_anterior = $linea =~ /^\s*$/;

	# Comentario de una sola línea
	if (my($antes, $spc, $cmnt) = $linea =~ m{^(.*) (\s*) [/][*] (.+) \s* [*][/] \s* $}x) {
	    next if $cmnt =~ /[@][{}]/;				# caso especial
	    $cmnt =~ s{^!<}{};					# caso especial
	    $cmnt =~ s{^\s*!}{};
	    $cmnt =~ s{^\s+|\s+$}{}g;
	    $linea = $antes ? sprintf("%-50s%s", $antes, "# $cmnt") : "# $cmnt";
	}

	# comentarios de varias líneas
	if (my $cmt = $linea =~ m{ ^ \s* [/] [*] }x .. $linea =~ m{ [*] [/] $ }x) {
	    $linea =~ s{^ \s* [/] [*] \s* }{}x;
	    $linea =~ s{  \s* [*] [/] $   }{}x;
	    $linea =~ s{^ \s* [*] \s*     }{}x;
	    $linea =~ s{^ \s* !           }{}x;
	    $linea = "# $linea";
	}

	$resultado .= "$linea\n";
    }

    $TILENGINE_H = $resultado;
}
sub typedef_enum {					# líneas typedef enum de una sola línea
    my $resultado;
    my @cache;

    for my $linea (split /\n/, $TILENGINE_H) {

	if ($linea =~ m/^typedef enum$/ .. $linea =~ m/^(?<nombre_enum>\w+)[;]$/) {
	    my $nombre_enum = $+{nombre_enum} // '';
	    next if $linea =~ /^(?:typedef enum|[{}])/;	# primera línea
	    if ($nombre_enum) {
		$resultado .= "my Int enum $nombre_enum (\n";
		my $cnt = 0;
		for my $cache (@cache) {
		    $cache =~ m{^ \s* $re_nombre (?:$re_valor)? [,]? (?:\s* $re_comentario)? $}x;
		    my $variable = $+{nombre} // "ERROR: [$cache]";
		    my $valor = $+{valor} // $cnt;
		    $valor = parsea_expr($valor);
		    my $cmt = $+{comentario} // '';
		    $linea = sprintf "    %-25s => %-15s  %s", $variable, "$valor,", $cmt;
		    $resultado .= "$linea\n";
		    $cnt++;
		}
		$resultado .= ");\n";
		@cache = ();
		next;
	    }
	    else {
		push @cache, $linea;
		next;
	    }
	}

	$resultado .= "$linea\n";
    }

    $TILENGINE_H = $resultado;
}
sub typedef_tipos {					# líneas typedef de una línea
    my $resultado;
    my %nuevos;
    my $nuevos;

    for my $linea (split /\n/, $TILENGINE_H) {
	if ($linea =~ m{^typedef\s+(?!struct)(?<tipo>.+?)\s+(?<nuevotipo>\w+);(?:\s+$re_comentario)?}) {
	    my($tipo, $nuevotipo, $cmt) = @+{qw(tipo nuevotipo comentario)};

	    if ($tipo =~ /struct/) {
	    	say "AAAgggg";
	    	exit;
	    }
	    # caso especial que no necesitamos
	    if ($nuevotipo =~ /(?:bool|true|false)/) {
		next;
	    }

	    # definición del nuevo tipo
	    $tipo = $tipos_predefinidos{$tipo} // $tipo;	# pasar a tipo nativo
	    $tipos_predefinidos{$nuevotipo} = $tipo;		# guardar la relación entre el definido y el nativo

	    $nuevos{$nuevotipo} = $tipo;
	    $nuevos = join "|", keys %nuevos;

	    next;
	}
	else {
	    # hacer el cambio de nuevos tipos en la línea
	    $linea =~ s{\b($nuevos)\b(?![*])}{$nuevos{$1}}ge if $nuevos;
	    $linea =~ s{\b($nuevos)\b\s*[*]}{Pointer}g if $nuevos;
	}

	$resultado .= "$linea\n";
    }

    $TILENGINE_H = $resultado;
}
sub pone_punteros {					# cambia 'struct *' a Pointer y 'const char *' a Str
    my $resultado;

    for my $linea (split /\n/, $TILENGINE_H) {
	$linea =~ s{const char\s*[*]\s*}{Str }g;
	$linea =~ s{(?<!typedef )struct (\w+)\s*[*]\s*(\w+)}{Pointer $2}g;
	$linea =~ s{(?<!typedef )struct (\w+)\s*[*]\s*(?=\W)}{"Pointer " . lc $1}ge;
	$resultado .= "$linea\n";
    }

    $TILENGINE_H = $resultado;
}
sub typedef_struct_linea {				# líneas typedef struct de una sola línea
    my $resultado;

    for my $linea (split /\n/, $TILENGINE_H) {
	if ($linea =~ m/^typedef struct\s+(?<tipo>\S+)\s+(?<nuevotipo>\w+);(?:\s*$re_comentario)?/) {
	    my($tipo, $nuevotipo, $comentario) = @+{qw(tipo nuevotipo comentario)};
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
	    $linea = sprintf "%-50s%s",
			(($tipo eq 'Pointer') ? "class $nuevotipo is repr('CPointer') { }"
					      : "class $nuevotipo is $tipo is export { }"),
			$comentario
		   ;
	}

	$resultado .= "$linea\n";
    }

    $TILENGINE_H = $resultado;
}
sub parsea_expr ($expr) {
    $expr =~ s/>>/+>/g;
    $expr =~ s/<</+</g;
    $expr =~ s/[|]/+|/g;
    return $expr;
}
sub typedef_struct {					# líneas de typedef struct
    my $resultado;
    my @cache;

    for my $linea (split /\n/, $TILENGINE_H) {
	if ($linea =~ m/^typedef struct(?:\s+\w+)?$/ .. $linea =~ m/^(?<nombre_struct>\w+)[;]$/) {
	    my $nombre_struct = $+{nombre_struct} // '';
	    next if $linea =~ /^(?:typedef struct|[{}])/;	# primera línea
	    if ($nombre_struct) {
		#$structs{$nombre_struct} = 1;
		$resultado .= "class $nombre_struct is repr('CStruct') is export  {\n";
		for my $cache (@cache) {
		    $cache =~ m{^ \s* (?<tipo>\w+) \s+ (?<nombre>\w+) [;] (?:\s* $re_comentario)? $}x;
		    my($tipo, $nombre, $comentario) = @+{qw(tipo nombre comentario)};
		    $tipo = $tipos_predefinidos{$tipo} // $tipo;
		    $linea = sprintf "    has %-15s\$.%-15sis rw;    %s", $tipo, $nombre, $comentario; 
		    $resultado .= "$linea\n";
		}
		$resultado .= "}\n";
		@cache = ();
		next;
	    }
	    else {
		push @cache, $linea;
		next;
	    }
	}

	$resultado .= "$linea\n";
    }

    $TILENGINE_H = $resultado;
}
sub funciones {						# líneas con declaración de funciones
    my $resultado;

    for my $linea (split /\n/, $TILENGINE_H) {

	$resultado .= "$linea\n";
    }

    $TILENGINE_H = $resultado;
}
sub cambia_tipos {
    my $org = shift;

    #say "[$org]" if $org =~ /callback/;

    $org =~ s/void \(\*callback\)\(int\)/&callback (int32)/;
    $org =~ s/const char\s*[*]/Str/g;
    #$org =~ s/[*]$/ is rw/g;

    while (my($tipo, $nuevotipo) = each %tipos_predefinidos) {
	#if ($org =~ /BYTE/) {
	#    warn "Tipo: [$tipo] Nuevo: [$nuevotipo] Org: [$org]\n";
	#}
	#if ($org =~ /BYTE/) {
	#    warn "Tipo: [$tipo] Nuevo: [$nuevotipo] Org: [$org]";
	#}
	$org =~ s/\b$tipo\b/$nuevotipo/g;
    }
    #$org =~ s/int/int32/g;
    #$org =~ s/BYTE/uint8/g;
    #$org =~ s/DWORD/int32/g;
    #$org =~ s/const char ?[*]/Pointer/g;

    return $org;
}


__END__
	#if ($linea =~ /^\s+(?<retorno>const \w+ [*]|\w+[*]?\s+)(?<function>\w+) ?\((?<args>.+?)\);/) {
	if ($linea =~ /^\s+(?<retorno>.+)\s+(?<function>[*]?\w+)\s+\((?<args>.+?)\);/) {
	    my($retorno, $function, $args) = @+{qw(retorno function args)};
	    if ($function =~ s/^[*]//) {
		$retorno .= " *";
	    }
	    #say "[$function]($args)=>[$retorno]";

	    # transformar los argumentos a tipos estándar

	    ## crear los dos tipos de argumentos
	    ## 1. Argumentos solo tipos
	    my @args_solo_tipos;
	    my @args_solo_vars;
	    my @args_tipos_vars;
	    for my $arg (split /, ?/, $args) {
		#say $arg;
		my($orgtipo,$var) = $arg =~ /^(void(?:.+)?|.+?)(?: [*]?(\w+))?$/;
		if ($orgtipo eq 'void (*callback)(int)') {
		    push @args_solo_vars, '$callback';
		    push @args_solo_tipos, '&callback (int32)';
		    push @args_tipos_vars, 'Pointer $callback';
		}
		else {
		    if ($var and $var =~ s/^[*]//) {
			$orgtipo .= " *";
		    }
		    my $tipo = cambia_tipos($orgtipo);
		    if (not $var) {
			($var) = $tipo =~ m/(\w+)/;
		    }
		    
		    my $es_puntero = $tipo =~ s/\s*[*]$//;
		    if (not exists $tipos_predefinidos{$orgtipo} ) { # and not exists $constants{$orgtipo}) {
			push @args_solo_tipos, 'Pointer';
		    }
		    else {
			push @args_solo_tipos,  $tipo;
		    }
		    
		    if (not $var) {
		        $var = $tipo;
		        $var =~ s/TLN_/\$/;
			$tipo = "$tipo is rw" if $es_puntero;
		    }
		    push @args_solo_vars,  "\$$var";
		    push @args_tipos_vars, "$tipo \$$var";
		}
	    }

	    my $solo_tipos = join ', ' => @args_solo_tipos;
	    my $solo_vars  = join ', ' => @args_solo_vars;
	    my $tipos_var  = join ', ' => @args_tipos_vars;

	    ## 2. Argumentos tipos y parámetros

	    # valor de retorno
	    my $returns = cambia_tipos($retorno);
	    $retorno = '';
	    if ($returns =~ /[*]$/) {
		$returns = 'Pointer';
	    }
	    if ($returns and $returns ne 'void') {
		$retorno = " returns $returns";
	    }

	    # crear nombre de método
	    my $method = $function =~ s/^TLN_//r;

	    $resultado .= "my sub $function($solo_tipos)$retorno is native('Tilengine') { * }\n";
	    $resultado .= "method $method($tipos_var) { $function($solo_vars) }\n";
	    $resultado .= "\n";

	    ## my sub $funcion_ref->[0](int32, int32, int32, int32, int32) returns bool is native('Tilengine') { * };
	    ## method Init (int32 $hres, int32 $vres, int $numlayers, int $numsprites, int $numanimations) { TLN_Init($hres, $vres, $numlayers, $numsprites, $numanimations) };

	    next;
	}


#- Variables -----------------------------------------------------------------------------------------------------------
my @cache;
my %structs;
my %constants;

#- Proceso -------------------------------------------------------------------------------------------------------------
__END__
use Data::Dumper; # XXX

#- Inicialización ------------------------------------------------------------------------------------------------------
my $en_cmt = 'E0';
my %tipos_definidos;

my %constants;

my @funciones;
my($y, $m, $d) = (localtime)[5, 4, 3];
$m++;

