-- GangWarsRP - F4 Menu Tab Registration API
-- Other modules register their tabs here; the F4 menu reads them

GWRP.F4Tabs = GWRP.F4Tabs or {}

-- Build the tab list from all enabled modules that have f4_tab defined
function GWRP.F4Tabs:BuildTabList()
    local tabs = {}

    for moduleID, mod in pairs(GWRP.Modules:GetAll()) do
        if mod.enabled and mod.loaded and mod.f4_tab then
            local tab = table.Copy(mod.f4_tab)
            tab.moduleID = moduleID
            table.insert(tabs, tab)
        end
    end

    -- Sort by order
    table.sort(tabs, function(a, b)
        return (a.order or 999) < (b.order or 999)
    end)

    return tabs
end

-- Check if a tab should be visible for a specific player
function GWRP.F4Tabs:IsTabVisible(tab, ply)
    if not tab then return false end

    -- Check visibility function if defined
    if tab.visible and type(tab.visible) == "function" then
        return tab.visible(ply)
    end

    return true
end
