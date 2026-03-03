-- GangWarsRP - Territory Config for rp_downtown_v2

GWRP.Territory = GWRP.Territory or {}
GWRP.Territory.Zones = GWRP.Territory.Zones or {}

-- Zone definitions: each zone has bounds, a name, and a capture point position
GWRP.Territory.Zones["downtown_plaza"] = {
    name = "Downtown Plaza",
    min = Vector(-2000, -2000, -200),
    max = Vector(0, 0, 500),
    capturePoint = Vector(-1000, -1000, 0),
    owner = "",
    captured_at = 0,
}

GWRP.Territory.Zones["industrial_district"] = {
    name = "Industrial District",
    min = Vector(0, -2000, -200),
    max = Vector(2000, 0, 500),
    capturePoint = Vector(1000, -1000, 0),
    owner = "",
    captured_at = 0,
}

GWRP.Territory.Zones["residential_area"] = {
    name = "Residential Area",
    min = Vector(-2000, 0, -200),
    max = Vector(0, 2000, 500),
    capturePoint = Vector(-1000, 1000, 0),
    owner = "",
    captured_at = 0,
}

GWRP.Territory.Zones["warehouse_district"] = {
    name = "Warehouse District",
    min = Vector(0, 0, -200),
    max = Vector(2000, 2000, 500),
    capturePoint = Vector(1000, 1000, 0),
    owner = "",
    captured_at = 0,
}
