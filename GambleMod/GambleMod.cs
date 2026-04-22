using BepInEx;
using Jotunn.Entities;
using Jotunn.Managers;

namespace GambleMod
{
    [BepInPlugin(PluginGUID, PluginName, PluginVersion)]
    [BepInDependency(Jotunn.Main.ModGuid)]
    //[NetworkCompatibility(CompatibilityLevel.EveryoneMustHaveMod, VersionStrictness.Minor)]
    internal class GambleMod : BaseUnityPlugin
    {
        public const string PluginGUID = "com.jotunn.GambleMod";
        public const string PluginName = "GambleMod";
        public const string PluginVersion = "0.0.1";

        private void Awake()
        {
          CommandManager.Instance.AddConsoleCommand(new GambleCommand());
        }
    }
}