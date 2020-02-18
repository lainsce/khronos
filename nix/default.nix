with import <nixpkgs> {};

stdenv.mkDerivation rec {
    name = "com.github.lainsce.khronos";
    version = "1.0.5";

    src = fetchFromGitHub {
        owner = "lainsce";
        repo = "khronos";
        rev = "1.0.5";
	sha256 = "0dk1b2d82gli3z35dn5p002lfkgq326janql0vn1z5hs8jvjakqh";
    };

    postPatch = ''
    	chmod +x meson/post_install.py
    	patchShebangs meson/post_install.py
    '';

    buildInputs = [
	libgee
	gtk3
	json-glib
	pantheon.granite
    ];

    nativeBuildInputs = [
	desktop-file-utils
    	meson
    	ninja
    	pkgconfig
    	python3
    	vala
    	wrapGAppsHook
    ];
}