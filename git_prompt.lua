local path = require('path')
local gitutil = require('gitutil')


function my_prompt_filter()
    cwd = clink.get_cwd()
    cwd = string.gsub(cwd, clink.get_env("USERPROFILE"), "~")
    local venv = clink.get_env("VIRTUAL_ENV")
    if not venv then
        venv = ""
    else
        venv = "("..path.basename(venv)..")"
    end
    prompt ="{venv}\x1b[1;32m{username}\x1b[0m\x1b[1;31m▶\x1b[0m\x1b[1;34m{cwd}\x1b[0m{git}\x1b[1;36m❯\x1b[0m "
    with_venv = string.gsub(prompt, "{venv}", venv)
    with_u_name = string.gsub(with_venv, "{username}", clink.get_env("USERNAME"))
    with_cwd = string.gsub(with_u_name, "{cwd}", cwd)
    local git_dir = gitutil.get_git_dir()
    if not git_dir then
        branch = false
    else
        branch = gitutil.get_git_branch(git_dir)
    end
    if branch then
        with_git = string.gsub(with_cwd, "{git}", "\x1b[1;36m◇\x1b[0m\x1b[1;35m"..branch.."\x1b[0m")
    else
        with_git = string.gsub(with_cwd, "{git}", "")
    end
    clink.prompt.value = with_git
end

clink.prompt.register_filter(my_prompt_filter, 1)