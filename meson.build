project('com.github.lainsce.khronos', ['vala', 'c'], version: '2.0.0')
gnome = import('gnome')
i18n = import('i18n')

add_project_arguments([
		'--target-glib=2.40',
	],
	language: 'vala',
)
add_project_arguments(
    '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()),
    language: 'c'
)

asresources = gnome.compile_resources(
    'as-resources', join_paths('data', 'style.gresource.xml'),
    source_dir: 'data',
    c_name: 'as'
)

sources = files(
    'src/Application.vala',
    'src/MainWindow.vala',
    'src/Services/TaskManager.vala',
    'src/Services/FileManager.vala',
    'src/Services/Dialog.vala',
    'src/Widgets/Column.vala',
    'src/Widgets/ColumnListBox.vala',
    'src/Widgets/Box.vala',
    'src/Widgets/EventBox.vala',
)

cc = meson.get_compiler('c')
m_dep = cc.find_library('m', required: true)
dependencies = [
    dependency('gio-2.0'),
    dependency('gtk+-3.0'),
    dependency('glib-2.0'),
    dependency('gobject-2.0'),
    dependency('gee-0.8'),
    dependency('libhandy-1'),
    dependency('granite'),
    dependency('json-glib-1.0'),
    m_dep,
]

# Let's define our executable
executable(
    meson.project_name(),
    sources,
    asresources,
    dependencies: dependencies,
    install : true
)

subdir('data')
subdir('po')

meson.add_install_script('meson/post_install.py', join_paths(get_option('prefix'), get_option('datadir')))
