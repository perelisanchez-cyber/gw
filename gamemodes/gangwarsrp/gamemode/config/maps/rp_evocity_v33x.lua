-- GangWarsRP - Territory Config for rp_evocity_v33x

GWRP.Territory = GWRP.Territory or {}
GWRP.Territory.Zones = GWRP.Territory.Zones or {}

-- Zone definitions for EvoCity
GWRP.Territory.Zones["city_center"] = {
    name = "City Center",
    min = Vector(-3000, -3000, -500),
    max = Vector(0, 0, 1000),
    capturePoint = Vector(-1500, -1500, 0),
    owner = "",
    captured_at = 0,
}

GWRP.Territory.Zones["slums"] = {
    name = "The Slums",
    min = Vector(0, -3000, -500),
    max = Vector(3000, 0, 1000),
    capturePoint = Vector(1500, -1500, 0),
    owner = "",
    captured_at = 0,
}

GWRP.Territory.Zones["suburbs"] = {
    name = "Suburbs",
    min = Vector(-3000, 0, -500),
    max = Vector(0, 3000, 1000),
    capturePoint = Vector(-1500, 1500, 0),
    owner = "",
    captured_at = 0,
}

GWRP.Territory.Zones["docks"] = {
    name = "The Docks",
    min = Vector(0, 0, -500),
    max = Vector(3000, 3000, 1000),
    capturePoint = Vector(1500, 1500, 0),
    owner = "",
    captured_at = 0,
}

GWRP.Territory.Zones["industrial_park"] = {
    name = "Industrial Park",
    min = Vector(3000, -3000, -500),
    max = Vector(6000, 0, 1000),
    capturePoint = Vector(4500, -1500, 0),
    owner = "",
    captured_at = 0,
}
