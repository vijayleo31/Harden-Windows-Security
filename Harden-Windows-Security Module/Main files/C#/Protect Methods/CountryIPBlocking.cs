#nullable enable

namespace HardenWindowsSecurity
{
    public partial class CountryIPBlocking
    {
        public static void Invoke()
        {
            HardenWindowsSecurity.Logger.LogMessage("Blocking IP ranges of countries in State Sponsors of Terrorism list", LogTypeIntel.Information);

            FirewallHelper.BlockIPAddressListsInGroupPolicy(
                "State Sponsors of Terrorism IP range blocking",
                "https://raw.githubusercontent.com/HotCakeX/Official-IANA-IP-blocks/main/Curated-Lists/StateSponsorsOfTerrorism.txt",
                true
                );           
        }
    }
}
