namespace GOTHIC_NAMESPACE
{
//@EXAMPLE START
    auto CGameManager_Init_Ivk = Union::CreateHook(ADDRESS_OF(&CGameManager::Init), &CGameManager::Init_Hooked);

    void CGameManager::Init_Hooked(HWND__*& handle)
    {
        constexpr const char* versions[] = {"", "Gothic I", "Gothic Sequel (:o)", "Gothic II Classic", "Gothic II Night of the Raven"};
        Union::String::Format("Hello World from MyPlugin Example!\nGame: {0}", versions[GetGameVersion()]).ShowMessage();
        // Execute original method
        (this->*CGameManager_Init_Ivk)(handle);
    }
//@EXAMPLE END
}