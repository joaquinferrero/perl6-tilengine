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

my $en_cmt = 'E0';

open my $FH_API, '<:crlf', '../../lib/Tilengine.h';
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

    # línas de defines
    if (my($nombre, $valor) = /^ \s* [#] \s* define \s+ (\S+) \s* (.*)/x) {
	$valor = 'undef' if not $valor;
	say parsea_define($nombre, $valor);
    	next;
    }

    # líneas de typedef de una línea
    if (m{^ typedef (?<tipo>.+?) \s+ (?<nuevotipo>\w+); (?: \s* [/] [*] (?<comentario>.+?) [*] [/])? }x) {
    	my $cmt = $+{comentario} // '';
    	$cmt = "\t\t# $cmt" if $cmt;
	say "TYPEDEF: $+{tipo} $+{nuevotipo} $cmt";
	# HERE guardar la definición de tipos en un hash
	next;
    }

    # comentarios de una línea
    if (my($cmt) = m{^ \s* [/] [*] (.*?) [*] [/]}x) {
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

    # Si llegamos aquí, nos hemos dejado algo
    say "ERROR: [$_]";
}
close $FH_API;

sub parsea_define($nombre, $valor) {
    my $define_funcion = 0;
    if ($nombre =~ /^ (.+?) \( (.+?) \)/x) {
	$nombre = "sub $1(\$$2) {";
	$define_funcion = $2;
    }
    else {
    	$nombre = "constant $nombre =";
    }
    $valor =~ s/<</+</g;
    $valor =~ s/[|]/+|/g;
    if ($define_funcion) {
	$valor =~ s/\b$define_funcion\b/\$$define_funcion/g;
	$valor .= " }";
    }

    return "$nombre $valor";
}

__END__

# Leer la API en C++
my @funciones;
    if (/^TLNAPI (?<retorno>const char [*]|\w+) ?(?<function>\w+) ?\((?<args>.+?)\);/) {
	#print;
    	#say "$+{function}($+{args})=>$+{retorno}\n";
    	push @funciones, [$+{function}, $+{args}, $+{retorno}];
    }

my($y, $m, $d) = (localtime)[5, 4, 3];
$m++;

open my $SALIDA, '>', "Tilengine.new.p6";

print $SALIDA <<EOL;
use v6;
unit module Tilengine:ver<$y.$m.$d>:auth<Joaquin Ferrero (jferrero\@gmail.com)>;

use NativeCall;

class Tilengine is export {

EOL

for my $funcion_ref (@funciones) {
    # transformar los argumentos a tipos estándar
    my $args = cambia_tipos($funcion_ref->[1]);

    # crear los dos tipos de argumentos
    # 1. Argumentos solo tipos
    my @args_solo_tipos;
    my @args_solo_vars;
    my @args_tipos_vars;
    for my $arg (split /, ?/, $args) {
    	say $arg;
    	my($tipo,$var) = $arg =~ /^(void(?:.+)?|.+?)(?: (\w+))?$/;
	#if (not defined $var) {
	#    $var = $tipo;
	#    $var =~ s/TLN_/\$/;
	#}
	push @args_solo_tipos,  $tipo;
	if ($var) {
	    say "$tipo|$var";
	    push @args_solo_vars,  "\$$var";
	    push @args_tipos_vars, "$tipo \$$var";
	}
	else {
	    say "$tipo";
	    push @args_tipos_vars, $tipo;
	}

    }
    my $solo_tipos = join ', ' => @args_solo_tipos;
    my $solo_vars  = join ', ' => @args_solo_vars;
    my $tipos_var  = join ', ' => @args_tipos_vars;

    # 2. Argumentos tipos y parámetros

    # valor de retorno
    my $returns = cambia_tipos($funcion_ref->[2]);
    my $retorno = '';
    if ($returns ne 'void') {
	$retorno = " returns $returns";
    }

    # crear nombre de método
    my $method = $funcion_ref->[0] =~ s/^TLN_//r;

    print $SALIDA "    my sub $funcion_ref->[0]($solo_tipos)$retorno is native('Tilengine') { * }\n";
    print $SALIDA "    method $method ($tipos_var) { $funcion_ref->[0]($solo_vars) };\n";
    print $SALIDA "\n";

    # my sub $funcion_ref->[0](int32, int32, int32, int32, int32) returns bool is native('Tilengine') { * };
    # method Init (int32 $hres, int32 $vres, int $numlayers, int $numsprites, int $numanimations) { TLN_Init($hres, $vres, $numlayers, $numsprites, $numanimations) };
}

print $SALIDA "}\n";

close $SALIDA;

sub cambia_tipos {
    my $org = shift;

    $org =~ s/int/int32/g;
    $org =~ s/BYTE/uint8/g;
    $org =~ s/DWORD/int32/g;
    $org =~ s/const char ?[*]/Pointer/g;

    return $org;
}

__END__

