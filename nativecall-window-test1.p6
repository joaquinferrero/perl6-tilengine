
use NativeCall;

=begin C
HWND WINAPI FindWindow(
  _In_opt_ LPCTSTR lpClassName,
  _In_opt_ LPCTSTR lpWindowName
);

HDC GetDC(
  _In_ HWND hWnd
);

int ReleaseDC(
  _In_ HWND hWnd,
  _In_ HDC  hDC
);

BOOL WINAPI GetClientRect(
  _In_  HWND   hWnd,
  _Out_ LPRECT lpRect
);

COLORREF SetPixel(
  _In_ HDC      hdc,
  _In_ int      X,
  _In_ int      Y,
  _In_ COLORREF crColor
);

BOOL BitBlt(
  _In_ HDC   hdcDest,
  _In_ int   nXDest,
  _In_ int   nYDest,
  _In_ int   nWidth,
  _In_ int   nHeight,
  _In_ HDC   hdcSrc,
  _In_ int   nXSrc,
  _In_ int   nYSrc,
  _In_ DWORD dwRop
);

int WINAPI MessageBox(
  _In_opt_ HWND    hWnd,
  _In_opt_ LPCTSTR lpText,
  _In_opt_ LPCTSTR lpCaption,
  _In_     UINT    uType
);
=end C

class RECT is repr('CStruct') {
    has num64 $.left is rw;
    has num64 $.top is rw;
    has num64 $.right is rw;
    has num64 $.bottom is rw;

    method Str {
        qq:to/END HERE/;
        left: { self.left }
        top: { self.top }
        right: { self.right }
        bottom: { self.bottom }
        END HERE
    }
}

sub FindWindowA(Str, Str) returns int64 is native('user32') { * }
sub GetDC(int64 $hWnd) returns int64 is native('user32') { * }
sub ReleaseDC(int64 $hWnd, int64 $hDC) returns int64 is native('user32') { * }
sub GetClientRect(int64, Pointer[RECT] is rw) returns int64 is native('user32') { * }
sub SetPixel(int64, int64, int64, int64) returns int64 is native('Gdi32') { * }
sub MessageBoxA(int32, Str, Str, int32) returns int32 is native('user32') { * }

# run "c:/windows/system32/SnippingTool.exe"

my $hWnd = FindWindowA(Str, 'Recortes');
die "target windows not found!" unless $hWnd != 0;

# my Pointer[RECT] $r .= new;
# GetClientRect($hWnd, $r);

my $hDC = GetDC($hWnd);
for [^300] -> $i {
	for [^300] -> $j {
		SetPixel($hDC, $i, $j, 0xFF0033);
	}
}

ReleaseDC($hWnd, $hDC);
