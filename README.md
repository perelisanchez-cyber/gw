# GangWarsRP - Garry's Mod Gamemode

A custom gang-based dark roleplaying gamemode for Garry's Mod. Players join or create gangs, claim territory, earn money through jobs and illegal activities, and wage war against rival gangs for dominance.

## Features

- **Modular Architecture** — Every system is a self-contained module that can be enabled/disabled via config
- **F4 Menu** — Primary player interface for all major actions (jobs, gangs, shops, inventory, settings)
- **Gang System** — Create gangs, manage ranks, declare wars, gang chat
- **Territory Control** — Capture zones on the map for passive income and perks
- **Economy** — Wallet/bank system, salary, money printers, transactions
- **Job System** — Legal and illegal jobs with loadouts, salaries, and slot limits
- **Police & Wanted** — Warrants, arrests, jail, lockdowns, bail
- **Shops** — Buy weapons, items, entities, and vehicles
- **Inventory** — Slot-based persistent inventory system
- **HUD** — Clean, minimal overlay with customizable settings
- **Admin Panel** — Player management, module toggles, server configuration

## Installation

1. Clone this repository into your Garry's Mod server's gamemodes directory:
   ```
   cd garrysmod/gamemodes/
   git clone https://github.com/YOUR_USERNAME/gangwarsrp.git gangwarsrp
   ```

2. Set the gamemode in your server's command line or `server.cfg`:
   ```
   gamemode gangwarsrp
   ```

3. Restart your server.

## Configuration

All configuration is managed through `gamemodes/gangwarsrp/gamemode/core/sh_config.lua`.

### Module Toggles

Enable or disable any module individually:

| Module    | Description                          | Default |
|-----------|--------------------------------------|---------|
| f4menu    | Core F4 menu UI (always enabled)     | ON      |
| gangs     | Gang creation and management         | ON      |
| territory | Territory capture and control        | ON      |
| economy   | Wallet, bank, and transactions       | ON      |
| jobs      | Job/class system                     | ON      |
| inventory | Slot-based inventory                 | ON      |
| hud       | HUD overlay and notifications        | ON      |
| police    | Wanted/warrant/arrest system         | ON      |
| shops     | Weapon/item/entity shops             | ON      |
| admin     | Admin panel and commands             | ON      |

### Global Settings

Tweak gameplay values like starting money, salary intervals, gang size limits, and more in `sh_config.lua`.

## Module System

Every feature is a self-contained module under `gamemode/modules/`. Modules:

- Register via a `sh_module.lua` manifest file
- Declare hard and soft dependencies on other modules
- Can register F4 menu tabs and chat commands
- Expose public APIs on `GWRP.<ModuleName>`
- Communicate via hooks — never reference another module's internals directly

## Tech Stack

- **Language:** Lua (GLua)
- **Engine:** Source Engine (Garry's Mod)
- **Networking:** Garry's Mod net library
- **Storage:** SQLite via `sql.Query()`
- **UI:** Derma (VGUI framework)

## Project Structure

```
gamemodes/gangwarsrp/
├── gangwarsrp.txt          — Gamemode metadata
└── gamemode/
    ├── init.lua            — Server entry point
    ├── cl_init.lua         — Client entry point
    ├── shared.lua          — Shared globals and net strings
    ├── core/               — Core framework files
    ├── modules/            — Feature modules
    ├── config/             — Configuration files
    └── entities/           — Custom entities and weapons
```

## License

See [LICENSE](LICENSE) for details.
