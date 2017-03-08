#!/usr/bin/env perl
#
# Conversor de la API desde C++ a Perl 6 (escrito en Perl 5)
# Joaquín Ferrero
# 
# Primera versión: 23/02/2017
# Segunda versión: 02/03/2017
# Tercera versión: 06/03/2017
#
use v5.14;
use strict;
use warnings;
use feature qw'signatures';
no warnings "experimental::signatures";
use autodie;
use FindBin qw($Bin);

#- Lectura de la biblioteca en C++ -------------------------------------------------------------------------------------
my $file_lib	     = 'Tilengine.h';
my @path_tilengine_h = ("$Bin/../../lib/$file_lib", "/usr/include/$file_lib");

#my $convertido;
#for my $path_tilengine_h (@path_tilengine_h) {
#    if (-f $path_tilengine_h) {
#	local $/;
#	open my $FHL, '<:crlf', $path_tilengine_h;
#	open my $FHE, '>', "$Bin/$file_lib";
#	print   $FHE scalar <$FHL>;
#	close   $FHL;
#	close   $FHE;
#	$convertido = 'si';
#	last;
#    }
#}
#if (not $convertido) {
#    die "ERROR: No encuento la biblioteca [$file_lib]\n";
#}


#- Preprocesamiento ----------------------------------------------------------------------------------------------------
my $Tilengine_h;
{
    for my $path_tilengine_h (@path_tilengine_h) {
        if (-f $path_tilengine_h) {
	    local $/;
	    # Limpieza de los finales de línea
	    open my $TLH, '<:crlf', $path_tilengine_h;
	    my $tmp = <$TLH>;
	    close $TLH;
	    open  $TLH, '>', $file_lib;
	    print $TLH $tmp;
	    close $TLH;

	    # preprocesamiento usando el comando cpp
	    open my $FH, "cpp -C -D_LIB $file_lib |";
	    $Tilengine_h = <$FH>;
	    close $FH;
	    last;
	}
    }
}

#- Constantes ----------------------------------------------------------------------------------------------------------
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

#- Variables -----------------------------------------------------------------------------------------------------------
my @cache;
my %structs;
my %constants;

#- Patrones ------------------------------------------------------------------------------------------------------------
my $re_nombre     = qr{ (?<nombre>\b \w+ \b) }x;
my $re_valor      = qr{ \s* = \s* (?<valor>.+?) }x;
my $re_comentario = qr{ (?<comentario>\# .+) }x;

#- Proceso -------------------------------------------------------------------------------------------------------------
say "use v6;";
say "unit class Tilengine:ver<2017.03.06>:auth<Joaquin Ferrero (jferrero\@gmail.com)>;";
say "";
say "use NativeCall;";
say "";

my $coment_en_linea_anterior;

for my $linea (split /\n/, $Tilengine_h) {
    next if $linea =~ /^# 1 "$file_lib"/ ... $linea =~ /^# 1 "$file_lib"/;	# Preámbulo
    next if $linea =~ /^# \d+ "$file_lib"/;
    next if $linea =~ /^\s*$/ and $coment_en_linea_anterior;			# Líneas vacías
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

    # líneas de typedef struct de una línea
    if ($linea =~ m/^typedef struct\s+(?<tipo>\S+)\s+(?<nuevotipo>\w+);(?:\s*$re_comentario)?/) {
	my($tipo, $nuevotipo) = @+{qw(tipo nuevotipo)};
	my $es_puntero;
	if ('*' eq substr $tipo, -1, 1) {
	    $tipo = substr $tipo, 0, -1;
	    $es_puntero = 1;
	}
	if (not $tipos_predefinidos{$tipo}) {
	    warn "TIPO NO DEFINIDO: $tipo. Se cambia a Pointer";
	    $tipo = 'Pointer';
	    #$tipos_predefinidos{$nuevotipo} = $tipo;
	}
	#if ($es_puntero) {
	#    $tipo = "Pointer[$tipo]";
	#}
	$linea = ($tipo eq 'Pointer') ? "class $nuevotipo is repr('CPointer') { }"
	       : "class $nuevotipo is $tipo is export { }";
    }

    # líneas de typedef de una línea
    if ($linea =~ m{^typedef\s+(?<tipo>.+?)\s+(?<nuevotipo>\w+);(?:\s+$re_comentario)?}) {
    	my $cmt = $+{comentario} // '';
    	my($tipo, $nuevotipo) = @+{qw(tipo nuevotipo)};
	#$cmt = "$+{sp}# $cmt" if $cmt;
	#say "TYPEDEF: $tipo $nuevotipo $cmt";
	# cambiar los tipos
	$tipo = $tipos_predefinidos{$tipo} // $tipo;
	$constants{$nuevotipo} = 1;
	$nuevotipo = "constant $nuevotipo";
	#if ($constants{$nuevotipo} or $nuevotipo =~ /(?:bool|true|false)/) {
	if ($nuevotipo =~ /(?:bool|true|false)/) {
	    $nuevotipo = "#$nuevotipo";
	}
	$linea = sprintf "%-50s%s", "$nuevotipo = $tipo;", $cmt;
	#$constants{$nuevotipo} = $tipo;
    }

    # líneas de typedef enum
    if ($linea =~ m/^typedef enum$/ .. $linea =~ m/^(?<nombre_enum>\w+)[;]$/) {
    	my $nombre_enum = $+{nombre_enum} // '';
    	next if $linea =~ /^(?:typedef enum|[{}])/;
	if ($nombre_enum) {
	    say "my Int enum $nombre_enum (";
	    my $cnt = 0;
	    for my $cache (@cache) {
		$cache =~ m{^ \s* $re_nombre (?:$re_valor)? [,]? (?:\s* $re_comentario)? $}x;
		my $variable = $+{nombre} // "ERROR: [$cache]";
		my $valor = $+{valor} // $cnt;
		$valor = parsea_expr($valor);
		my $cmt = $+{comentario} // '';
		$linea = sprintf "%-50s%s", "    $variable => $valor,", $cmt;
		say $linea;
		$cnt++;
	    }
	    say ");";
	    @cache = ();
	}
	else {
	    push @cache, $linea;
	}
	next;
    }

    # líneas de typedef struct
    if ($linea =~ m/^typedef struct(?:\s+\w+)?$/ .. $linea =~ m/^(?<nombre_struct>\w+)[;]$/) {
    	my $nombre_struct = $+{nombre_struct} // '';
    	next if $linea =~ /^(?:typedef struct|[{}])/;
    	if ($nombre_struct) {
	    $structs{$nombre_struct} = 1;
	    say "class $nombre_struct is repr('CStruct') is export  {";
	    for my $cache (@cache) {
	    	$cache =~ m{^ \s* (?<tipo>\w+) \s+ (?<nombre>\w+) [;] (?:\s* $re_comentario)? $}x;
	    	my($tipo, $nombre, $comentario) = @+{qw(tipo nombre comentario)};
		$tipo = $tipos_predefinidos{$tipo} // $tipo;
		$linea = sprintf "%-50s%s", "    has $tipo\t\$.$nombre\tis rw;", $comentario; 
		say $linea;
	    }
	    say "}";
	    @cache = ();
	}
	else {
	    push @cache, $linea;
	}
    	next;
    }

    # líneas con declaración de funciones
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
	    #if (not defined $var) {
	    #    $var = $tipo;
	    #    $var =~ s/TLN_/\$/;
	    #}
	    if ($var and $var =~ s/^[*]//) {
	    	$orgtipo .= " *";
	    }

	    my $tipo = cambia_tipos($orgtipo);
	    
	    my $es_puntero = $tipo =~ s/\s*[*]$//;
	    if (not exists $tipos_predefinidos{$orgtipo} and not exists $constants{$orgtipo}) {
		push @args_solo_tipos, 'Pointer';
	    }
	    else {
		push @args_solo_tipos,  $tipo;
	    }
	    
	    if ($var) {
		#say "$tipo|$var";
		#$var = "$var is rw" if $es_puntero;
		push @args_solo_vars,  "\$$var";
		push @args_tipos_vars, "$tipo \$$var";
	    }
	    else {
		#say "$tipo";
		$tipo = "$tipo is rw" if $es_puntero;
		push @args_tipos_vars, $tipo;
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

	say "my sub $function($solo_tipos)$retorno is native('Tilengine') { * }";
	say "method $method($tipos_var) { $function($solo_vars) }";
	say "";

	## my sub $funcion_ref->[0](int32, int32, int32, int32, int32) returns bool is native('Tilengine') { * };
	## method Init (int32 $hres, int32 $vres, int $numlayers, int $numsprites, int $numanimations) { TLN_Init($hres, $vres, $numlayers, $numsprites, $numanimations) };

	next;
    }

    say $linea;
}

#- Subrutinas ----------------------------------------------------------------------------------------------------------
sub parsea_expr ($expr) {
    $expr =~ s/>>/+>/g;
    $expr =~ s/<</+</g;
    $expr =~ s/[|]/+|/g;
    return $expr;
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
use experimental 'switch';
use Data::Dumper; # XXX

#- Inicialización ------------------------------------------------------------------------------------------------------
my $en_cmt = 'E0';
my %tipos_definidos;

my %constants;

    # Si llegamos aquí, nos hemos dejado algo
    say "ERROR: [$_]";
}

my @funciones;
my($y, $m, $d) = (localtime)[5, 4, 3];
$m++;


print $SALIDA "}\n";

close $SALIDA;

