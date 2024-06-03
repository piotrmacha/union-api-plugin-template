#include <Union/Hook.h>
#include <ZenGin/zGothicAPI.h>
#include "Union/HookUtils.hpp"

#ifdef __G1
#pragma warning(push)
#pragma warning(disable: 4005)
#define GOTHIC_NAMESPACE Gothic_I_Classic
#define ENGINE Engine_G1
HOOKSPACE_WITH_SG_FILE(Gothic_I_Classic, GetGameVersion() == ENGINE, "Signatures_G1.tsv");
#include "Plugin.hpp"
#include "Plugin_G1.hpp"
#pragma warning(pop)
#endif

#ifdef __G1A
#pragma warning(push)
#pragma warning(disable: 4005)
#define GOTHIC_NAMESPACE Gothic_I_Addon
#define ENGINE Engine_G1A
HOOKSPACE_WITH_SG_FILE(Gothic_I_Addon, GetGameVersion() == ENGINE, "Signatures_G1A.tsv");
#include "Plugin.hpp"
#include "Plugin_G1A.hpp"
#pragma warning(pop)
#endif

#ifdef __G2
#pragma warning(push)
#pragma warning(disable: 4005)
#define GOTHIC_NAMESPACE Gothic_II_Classic
#define ENGINE Engine_G2
HOOKSPACE_WITH_SG_FILE(Gothic_II_Classic, GetGameVersion() == ENGINE, "Signatures_G2.tsv");
#include "Plugin.hpp"
#include "Plugin_G2.hpp"
#pragma warning(pop)
#endif

#ifdef __G2A
#pragma warning(push)
#pragma warning(disable: 4005)
#define GOTHIC_NAMESPACE Gothic_II_Addon
#define ENGINE Engine_G2A
HOOKSPACE_WITH_SG_FILE(Gothic_II_Addon, GetGameVersion() == ENGINE, "Signatures_G2A.tsv");
#include "Plugin.hpp"
#include "Plugin_G2A.hpp"
#pragma warning(pop)
#endif

#undef GOTHIC_NAMESPACE
#undef ENGNE
HOOKSPACE(Global, true);

