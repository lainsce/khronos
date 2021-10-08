project('khronos',
          version: '4.0.0',
    meson_version: '>= 0.50.0',
  default_options: [ 'warning_level=2',
                   ],
)

i18n = import('i18n')
gnome = import('gnome')

name       	= 'Khronos'
version    	= meson.project_version()
app_id     	= 'io.github.lainsce.Khronos'
profile    	= get_option('profile')
vcs_tag    	= run_command('git', 'rev-parse', '--short', 'HEAD').stdout().strip()
localedir  	= join_paths(get_option('prefix'), get_option('localedir'))
datadir    	= join_paths(get_option('prefix'), get_option('datadir'))
pkgdatadir 	= join_paths(get_option('prefix'), get_option('datadir'), app_id)
gettext_package = meson.project_name()

cargo_sources = files(
  'Cargo.toml',
  'Cargo.lock',
)

dependency('glib-2.0', version: '>= 2.66')
dependency('gio-2.0', version: '>= 2.66')
dependency('gtk4', version: '>= 4.5.0')
dependency('libadwaita-1', version: '>=1.0.0')

rust_sources = files(
  'src/main.rs',
  'src/i18n.rs',

  'src/ui/mod.rs',
  'src/ui/log.rs',
  'src/ui/logrow.rs',
  'src/ui/window.rs',
)

sources = [cargo_sources, rust_sources]

cargo_script = find_program(join_paths(meson.source_root(), 'build-aux/cargo.sh'))
cargo_release = custom_target(
  'cargo-build',
  build_by_default: true,
  input: sources,
  output: meson.project_name(),
  console: true,
  install: true,
  install_dir: get_option('bindir'),
  command: [
    cargo_script,
    meson.build_root(),
    meson.source_root(),
    '@OUTPUT@',
    get_option('buildtype'),
    meson.project_name(),
  ]
)

subdir('src')
subdir('data')
subdir('po')

meson.add_install_script('build-aux/meson/postinstall.py')
