#include <gio/gio.h>

#if defined (__ELF__) && ( __GNUC__ > 2 || (__GNUC__ == 2 && __GNUC_MINOR__ >= 6))
# define SECTION __attribute__ ((section (".gresource.as"), aligned (8)))
#else
# define SECTION
#endif

static const SECTION union { const guint8 data[800]; const double alignment; void * const ptr;}  as_resource_data = { {
  0x47, 0x56, 0x61, 0x72, 0x69, 0x61, 0x6e, 0x74, 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x18, 0x00, 0x00, 0x00, 0xc8, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x28, 0x06, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 
  0x03, 0x00, 0x00, 0x00, 0x05, 0x00, 0x00, 0x00, 
  0x05, 0x00, 0x00, 0x00, 0x06, 0x00, 0x00, 0x00, 
  0x94, 0x5d, 0xdc, 0x97, 0x05, 0x00, 0x00, 0x00, 
  0xc8, 0x00, 0x00, 0x00, 0x07, 0x00, 0x4c, 0x00, 
  0xd0, 0x00, 0x00, 0x00, 0xd4, 0x00, 0x00, 0x00, 
  0x96, 0x91, 0x40, 0x55, 0x02, 0x00, 0x00, 0x00, 
  0xd4, 0x00, 0x00, 0x00, 0x0e, 0x00, 0x76, 0x00, 
  0xe8, 0x00, 0x00, 0x00, 0xf7, 0x02, 0x00, 0x00, 
  0xf5, 0xf3, 0xf7, 0xeb, 0x03, 0x00, 0x00, 0x00, 
  0xf7, 0x02, 0x00, 0x00, 0x08, 0x00, 0x4c, 0x00, 
  0x00, 0x03, 0x00, 0x00, 0x04, 0x03, 0x00, 0x00, 
  0x02, 0x79, 0x66, 0x14, 0x00, 0x00, 0x00, 0x00, 
  0x04, 0x03, 0x00, 0x00, 0x08, 0x00, 0x4c, 0x00, 
  0x0c, 0x03, 0x00, 0x00, 0x10, 0x03, 0x00, 0x00, 
  0xd4, 0xb5, 0x02, 0x00, 0xff, 0xff, 0xff, 0xff, 
  0x10, 0x03, 0x00, 0x00, 0x01, 0x00, 0x4c, 0x00, 
  0x14, 0x03, 0x00, 0x00, 0x18, 0x03, 0x00, 0x00, 
  0xc2, 0xaf, 0x89, 0x0b, 0x04, 0x00, 0x00, 0x00, 
  0x18, 0x03, 0x00, 0x00, 0x04, 0x00, 0x4c, 0x00, 
  0x1c, 0x03, 0x00, 0x00, 0x20, 0x03, 0x00, 0x00, 
  0x67, 0x69, 0x74, 0x68, 0x75, 0x62, 0x2f, 0x00, 
  0x03, 0x00, 0x00, 0x00, 0x73, 0x74, 0x79, 0x6c, 
  0x65, 0x73, 0x68, 0x65, 0x65, 0x74, 0x2e, 0x63, 
  0x73, 0x73, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x43, 0x07, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 
  0x78, 0xda, 0xad, 0x54, 0xc9, 0x6e, 0x83, 0x30, 
  0x10, 0xbd, 0xf3, 0x15, 0x96, 0x72, 0x09, 0x12, 
  0x20, 0x87, 0x2c, 0x6d, 0xc8, 0x25, 0xbd, 0xe4, 
  0x37, 0x2a, 0x83, 0x1d, 0xb0, 0x0a, 0x36, 0x32, 
  0xa6, 0x89, 0x54, 0xf5, 0xdf, 0x6b, 0x9b, 0xa5, 
  0xc4, 0x90, 0x34, 0x4d, 0x8b, 0x64, 0x94, 0x0c, 
  0x6f, 0xc6, 0x6f, 0x96, 0x37, 0x7b, 0x4c, 0x8e, 
  0x94, 0x11, 0x3f, 0xe1, 0x39, 0x17, 0xc0, 0xbc, 
  0x5f, 0x92, 0x84, 0x30, 0x09, 0x66, 0xdb, 0xcd, 
  0x76, 0x83, 0x57, 0x3b, 0xc7, 0x09, 0x68, 0xc2, 
  0x99, 0x5f, 0x65, 0x08, 0xf3, 0x13, 0xf8, 0x70, 
  0x80, 0x7a, 0xfc, 0x54, 0xbe, 0xf9, 0x03, 0x73, 
  0x04, 0x60, 0x79, 0x36, 0x67, 0xa9, 0x4e, 0x9c, 
  0xa3, 0xe4, 0x6d, 0x67, 0x80, 0xb1, 0xfa, 0x95, 
  0x0a, 0x5e, 0x33, 0xdc, 0x5c, 0x11, 0x01, 0x29, 
  0x10, 0xab, 0x4a, 0x24, 0xd4, 0x1d, 0x23, 0x08, 
  0x2d, 0x50, 0x4a, 0x22, 0xc0, 0x38, 0x23, 0xf6, 
  0xb7, 0xce, 0xfa, 0xe9, 0x04, 0x52, 0xea, 0x58, 
  0x75, 0xc1, 0x5a, 0x32, 0xe3, 0x3b, 0x34, 0x29, 
  0x02, 0xe6, 0xfb, 0x38, 0x7d, 0x35, 0x16, 0x0f, 
  0x2c, 0x02, 0xb8, 0x76, 0xdb, 0x98, 0x5c, 0x60, 
  0xa2, 0x40, 0x0b, 0xc5, 0xb4, 0xe2, 0x39, 0xc5, 
  0x00, 0xe5, 0x65, 0x86, 0xe6, 0x33, 0x08, 0xa1, 
  0x07, 0x60, 0x10, 0x76, 0xc0, 0x12, 0x61, 0x4c, 
  0x59, 0xaa, 0x90, 0x2a, 0xb1, 0xa1, 0xaf, 0x2f, 
  0x10, 0xa6, 0x75, 0x15, 0x81, 0x95, 0xb6, 0x7f, 
  0x3a, 0x86, 0x52, 0xcc, 0xcf, 0x1d, 0x9f, 0x06, 
  0x14, 0x73, 0x29, 0x79, 0x71, 0x91, 0x4d, 0xf3, 
  0x41, 0xf2, 0x72, 0xc2, 0x2a, 0x68, 0x9a, 0xc9, 
  0x29, 0xfb, 0xf0, 0x2e, 0x6d, 0x2f, 0x90, 0x48, 
  0x29, 0xeb, 0xc3, 0x8f, 0xc8, 0xe5, 0xe4, 0xa8, 
  0xe2, 0x2c, 0xfb, 0xec, 0xf6, 0x83, 0xae, 0x5e, 
  0x6b, 0x4a, 0x41, 0xcf, 0xaa, 0x5c, 0x03, 0xa0, 
  0x07, 0x66, 0x87, 0xc3, 0x41, 0x97, 0xe3, 0xa9, 
  0xad, 0x86, 0x55, 0xda, 0x0b, 0x2c, 0x0c, 0xba, 
  0x9a, 0x1d, 0x39, 0x93, 0xfe, 0x89, 0x34, 0xb9, 
  0x6c, 0x20, 0xec, 0x98, 0x9d, 0xbb, 0x41, 0x31, 
  0xff, 0xf5, 0x03, 0x4d, 0x03, 0x34, 0x4d, 0x53, 
  0x7e, 0x30, 0xbf, 0x1a, 0x59, 0xbf, 0x17, 0xa1, 
  0xeb, 0x59, 0xae, 0xe1, 0x9d, 0xae, 0xe1, 0xca, 
  0xed, 0xc6, 0x46, 0xf1, 0x88, 0x74, 0xf2, 0x58, 
  0xf0, 0xb2, 0x6d, 0xd6, 0xed, 0xb4, 0x9e, 0x9f, 
  0x2f, 0x7c, 0x2b, 0x92, 0x93, 0x44, 0x12, 0x1c, 
  0xa0, 0x44, 0xd2, 0x77, 0x24, 0x51, 0x9c, 0x93, 
  0xbb, 0xe2, 0xac, 0x7f, 0x0c, 0xf3, 0x17, 0x5e, 
  0xc0, 0xe8, 0xe6, 0x6e, 0x22, 0xd3, 0x02, 0x1e, 
  0x0d, 0x9e, 0x09, 0xea, 0x9f, 0x28, 0x96, 0x99, 
  0x92, 0xf7, 0xa8, 0x91, 0x97, 0x42, 0xb6, 0xb8, 
  0x3c, 0x94, 0x4d, 0x13, 0xa2, 0x56, 0x63, 0x3d, 
  0xa1, 0xec, 0x76, 0x35, 0xe4, 0x6a, 0x59, 0x21, 
  0xe1, 0xa7, 0x5a, 0x15, 0xca, 0x7b, 0xde, 0xcf, 
  0x84, 0xe4, 0xa0, 0x51, 0xc4, 0xf7, 0x98, 0x5c, 
  0xd9, 0x02, 0x13, 0x00, 0x54, 0x91, 0x0e, 0x02, 
  0x83, 0xad, 0x6b, 0x00, 0xbf, 0xdd, 0x16, 0x96, 
  0x5c, 0xd7, 0xbd, 0x2c, 0xfb, 0x35, 0xb2, 0x6e, 
  0xb6, 0xc5, 0x20, 0xcb, 0x61, 0xdf, 0xae, 0xaf, 
  0x54, 0x7d, 0xc6, 0x5b, 0xf3, 0xf1, 0x26, 0x99, 
  0xbb, 0xa3, 0x23, 0x4f, 0xea, 0xca, 0x1b, 0x5a, 
  0x32, 0xfe, 0x4e, 0x44, 0xbf, 0xc3, 0xee, 0x50, 
  0xac, 0xdd, 0x47, 0xa5, 0xb4, 0x1b, 0x22, 0xb5, 
  0xd1, 0xcb, 0xd0, 0xb5, 0x28, 0x19, 0x39, 0x90, 
  0xff, 0xed, 0xbd, 0xd5, 0xda, 0x1f, 0xa7, 0xe3, 
  0x37, 0xbd, 0x6f, 0x54, 0xfd, 0x05, 0xd1, 0x35, 
  0x33, 0x22, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
  0x00, 0x28, 0x75, 0x75, 0x61, 0x79, 0x29, 0x6b, 
  0x68, 0x72, 0x6f, 0x6e, 0x6f, 0x73, 0x2f, 0x00, 
  0x01, 0x00, 0x00, 0x00, 0x6c, 0x61, 0x69, 0x6e, 
  0x73, 0x63, 0x65, 0x2f, 0x02, 0x00, 0x00, 0x00, 
  0x2f, 0x00, 0x00, 0x00, 0x05, 0x00, 0x00, 0x00, 
  0x63, 0x6f, 0x6d, 0x2f, 0x00, 0x00, 0x00, 0x00
} };

static GStaticResource static_resource = { as_resource_data.data, sizeof (as_resource_data.data), NULL, NULL, NULL };
G_GNUC_INTERNAL GResource *as_get_resource (void);
GResource *as_get_resource (void)
{
  return g_static_resource_get_resource (&static_resource);
}
/*
  If G_HAS_CONSTRUCTORS is true then the compiler support *both* constructors and
  destructors, in a sane way, including e.g. on library unload. If not you're on
  your own.

  Some compilers need #pragma to handle this, which does not work with macros,
  so the way you need to use this is (for constructors):

  #ifdef G_DEFINE_CONSTRUCTOR_NEEDS_PRAGMA
  #pragma G_DEFINE_CONSTRUCTOR_PRAGMA_ARGS(my_constructor)
  #endif
  G_DEFINE_CONSTRUCTOR(my_constructor)
  static void my_constructor(void) {
   ...
  }

*/

#ifndef __GTK_DOC_IGNORE__

#if  __GNUC__ > 2 || (__GNUC__ == 2 && __GNUC_MINOR__ >= 7)

#define G_HAS_CONSTRUCTORS 1

#define G_DEFINE_CONSTRUCTOR(_func) static void __attribute__((constructor)) _func (void);
#define G_DEFINE_DESTRUCTOR(_func) static void __attribute__((destructor)) _func (void);

#elif defined (_MSC_VER) && (_MSC_VER >= 1500)
/* Visual studio 2008 and later has _Pragma */

#define G_HAS_CONSTRUCTORS 1

/* We do some weird things to avoid the constructors being optimized
 * away on VS2015 if WholeProgramOptimization is enabled. First we
 * make a reference to the array from the wrapper to make sure its
 * references. Then we use a pragma to make sure the wrapper function
 * symbol is always included at the link stage. Also, the symbols
 * need to be extern (but not dllexport), even though they are not
 * really used from another object file.
 */

/* We need to account for differences between the mangling of symbols
 * for Win32 (x86) and x64 programs, as symbols on Win32 are prefixed
 * with an underscore but symbols on x64 are not.
 */
#ifdef _WIN64
#define G_MSVC_SYMBOL_PREFIX ""
#else
#define G_MSVC_SYMBOL_PREFIX "_"
#endif

#define G_DEFINE_CONSTRUCTOR(_func) G_MSVC_CTOR (_func, G_MSVC_SYMBOL_PREFIX)
#define G_DEFINE_DESTRUCTOR(_func) G_MSVC_DTOR (_func, G_MSVC_SYMBOL_PREFIX)

#define G_MSVC_CTOR(_func,_sym_prefix) \
  static void _func(void); \
  extern int (* _array ## _func)(void);              \
  int _func ## _wrapper(void) { _func(); g_slist_find (NULL,  _array ## _func); return 0; } \
  __pragma(comment(linker,"/include:" _sym_prefix # _func "_wrapper")) \
  __pragma(section(".CRT$XCU",read)) \
  __declspec(allocate(".CRT$XCU")) int (* _array ## _func)(void) = _func ## _wrapper;

#define G_MSVC_DTOR(_func,_sym_prefix) \
  static void _func(void); \
  extern int (* _array ## _func)(void);              \
  int _func ## _constructor(void) { atexit (_func); g_slist_find (NULL,  _array ## _func); return 0; } \
   __pragma(comment(linker,"/include:" _sym_prefix # _func "_constructor")) \
  __pragma(section(".CRT$XCU",read)) \
  __declspec(allocate(".CRT$XCU")) int (* _array ## _func)(void) = _func ## _constructor;

#elif defined (_MSC_VER)

#define G_HAS_CONSTRUCTORS 1

/* Pre Visual studio 2008 must use #pragma section */
#define G_DEFINE_CONSTRUCTOR_NEEDS_PRAGMA 1
#define G_DEFINE_DESTRUCTOR_NEEDS_PRAGMA 1

#define G_DEFINE_CONSTRUCTOR_PRAGMA_ARGS(_func) \
  section(".CRT$XCU",read)
#define G_DEFINE_CONSTRUCTOR(_func) \
  static void _func(void); \
  static int _func ## _wrapper(void) { _func(); return 0; } \
  __declspec(allocate(".CRT$XCU")) static int (*p)(void) = _func ## _wrapper;

#define G_DEFINE_DESTRUCTOR_PRAGMA_ARGS(_func) \
  section(".CRT$XCU",read)
#define G_DEFINE_DESTRUCTOR(_func) \
  static void _func(void); \
  static int _func ## _constructor(void) { atexit (_func); return 0; } \
  __declspec(allocate(".CRT$XCU")) static int (* _array ## _func)(void) = _func ## _constructor;

#elif defined(__SUNPRO_C)

/* This is not tested, but i believe it should work, based on:
 * http://opensource.apple.com/source/OpenSSL098/OpenSSL098-35/src/fips/fips_premain.c
 */

#define G_HAS_CONSTRUCTORS 1

#define G_DEFINE_CONSTRUCTOR_NEEDS_PRAGMA 1
#define G_DEFINE_DESTRUCTOR_NEEDS_PRAGMA 1

#define G_DEFINE_CONSTRUCTOR_PRAGMA_ARGS(_func) \
  init(_func)
#define G_DEFINE_CONSTRUCTOR(_func) \
  static void _func(void);

#define G_DEFINE_DESTRUCTOR_PRAGMA_ARGS(_func) \
  fini(_func)
#define G_DEFINE_DESTRUCTOR(_func) \
  static void _func(void);

#else

/* constructors not supported for this compiler */

#endif

#endif /* __GTK_DOC_IGNORE__ */

#ifdef G_HAS_CONSTRUCTORS

#ifdef G_DEFINE_CONSTRUCTOR_NEEDS_PRAGMA
#pragma G_DEFINE_CONSTRUCTOR_PRAGMA_ARGS(resource_constructor)
#endif
G_DEFINE_CONSTRUCTOR(resource_constructor)
#ifdef G_DEFINE_DESTRUCTOR_NEEDS_PRAGMA
#pragma G_DEFINE_DESTRUCTOR_PRAGMA_ARGS(resource_destructor)
#endif
G_DEFINE_DESTRUCTOR(resource_destructor)

#else
#warning "Constructor not supported on this compiler, linking in resources will not work"
#endif

static void resource_constructor (void)
{
  g_static_resource_init (&static_resource);
}

static void resource_destructor (void)
{
  g_static_resource_fini (&static_resource);
}
