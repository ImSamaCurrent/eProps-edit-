Config = {}


Config.CustomProps = true

Config.Global = {
    -----------------------------------------------------------------------------------
    Framework = "newEsx", -- esx = trigger / newEsx = export for legacy new version
    SharedObject = "esx:getSharedObject",
    -----------------------------------------------------------------------------------
    ColorMenuR = 255, -- Bannière couleur R / Marker de suppression 
    ColorMenuG = 186, -- Bannière couleur G / Marker de suppression 
    ColorMenuB = 217, -- Bannière couleur B / Marker de suppression 
    ColorMenuA = 150, -- Bannière couleur A / Marker de suppression 
    TextColor = "~HC_30~", -- Couleur du texte pour tout le menu 
    LabelCustomsProps = "Props Customs",
    -----------------------------------------------------------------------------------
    PropsMax = 5, -- Props posable au maximum 
}

Config.Props = {

    {
        name = "Général", -- Nom de la catégorie 
        job = nil, -- job qui vois cette catégorie (nil = tout le monde)
        job2 = nil, -- job2 qui vois cette catégorie (nil = tout le monde)
        Props = {
            -- Label = Nom dans le menu 
            -- Model = https://forge.plebmasters.de/objects
            {Label = "Fauteil Roulant", Model = "prop_wheelchair_01"},
            {Label = "Chaise Camping", Model = "prop_skid_chair_01"},
            {Label = "Chaise de rue", Model = "v_ilev_chair02_ped"},
            {Label = "Canapé de rue", Model = "prop_rub_couch04"},
            {Label = "Lampe Led", Model = "prop_worklight_03a"},
            {Label = "Lampe Photo", Model = "prop_studio_light_03"},
            {Label = "Carton Drogue Blue", Model = "prop_mp_drug_pack_blue"},
            {Label = "Tabouret", Model = "prop_bar_stool_01"},
            {Label = "Caisse D'armes", Model = "prop_lev_crate_01"},
            {Label = "Chariot Lingot", Model = "prop_large_gold_alt_a"},
            {Label = "Transat", Model = "p_patio_lounger1_s"},
            {Label = "Chaise en Bois", Model = "prop_rock_chair_01"},
            {Label = "Sac Poubelle", Model = "prop_ld_rub_binbag_01"},
        },
    },

}