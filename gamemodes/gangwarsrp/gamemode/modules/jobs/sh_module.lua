-- Jobs Module Manifest

GWRP.Modules:Register({
    id = "jobs",
    name = "Job System",
    description = "Browse and switch jobs, salary, loadouts",
    version = "1.0.0",
    enabled = true,
    dependencies = {"economy"},
    soft_dependencies = {"gangs"},

    client = {
        "cl_jobs.lua",
    },
    server = {
        "sv_jobs.lua",
    },
    shared = {
        "sh_jobs.lua",
    },

    f4_tab = {
        label = "Jobs",
        icon = "icon16/user_suit.png",
        order = 10,
        panel_class = "GWRP_JobsPanel",
    },

    commands = {
        {cmd = "job", description = "Quick switch job", usage = "/job <jobname>"},
    },
})
