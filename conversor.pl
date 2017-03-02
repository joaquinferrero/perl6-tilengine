#!/usr/bin/env perl
#
# Conversor de la API desde C++ a Perl 6 (escrito en Perl 5)
# Joaquín Ferrero
# 
# Primera versión: 23/02/2016
#
use v5.24;
use feature 'signatures';
use strict;
use warnings;
no warnings "experimental::signatures";
use autodie;

my %tipos_predefinidos = (
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
    'const char ?[*]'	=> 'Pointer',
);

my $re_nombre     = qr{ (?<nombre>\b \w+ \b) }x;
my $re_valor      = qr{ \s* = \s* \K (?<valor>[^,]+) }x;
my $re_comentario = qr{ \s* [/][*] \s* \K (?<comentario>.+) (?>\s* [*][/]) }x;

my $en_cmt = 'E0';
my %tipos_definidos;
my @cache;

open my $FH_API, '<:crlf', '../../lib/Tilengine.h';

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
	say parsea_define($nombre, $valor);
    	next;
    }

    # líneas de typedef struct de una línea
    if (m/^typedef struct\s+(?<tipo>\S+)\s+(?<nuevotipo>\w+);(?:\s*$re_comentario)?/) {
	my $tipo = $+{tipo};
	my $nuevotipo = $+{nuevotipo};
	if ('*' eq substr $tipo, -1, 1) {
	    $tipo = substr $tipo, 0, -1;
	    $tipo = "Pointer[$tipo]";
	}
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
	say "constant $nuevotipo = $tipo;$cmt";
	$tipos_definidos{$nuevotipo} = $tipo;
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
	if ($returns ne 'void') {
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
close $FH_API;

sub cambia_tipos {
    my $org = shift;

    while (my($tipo, $nuevotipo) = each %tipos_predefinidos) {
	#if ($tipo =~ /const/) {
	#    say "Tipo: [$tipo] Nuevo: [$nuevotipo] Org: [$org]";
	#}
	$org =~ s/^$tipo$/$nuevotipo/g;
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
	$valor =~ s/\b$define_funcion\b/\$$define_funcion/g;
	$valor .= " }";
    }
    else {
    	$valor .= ';';
    }

    return "$nombre $valor";
}

__END__

my @funciones;
my($y, $m, $d) = (localtime)[5, 4, 3];
$m++;


print $SALIDA "}\n";

close $SALIDA;

