document.addEventListener("DOMContentLoaded", () => {
    const container = document.getElementById("command-container");
    const closeButton = document.getElementById("close-btn");
    const commandsList = document.getElementById("commands-list");
    const keybindsList = document.getElementById("keybinds-list");
    const tabs = document.querySelectorAll(".tab");
    const tabContents = document.querySelectorAll(".tab-content");

    closeButton.addEventListener("click", () => {
        container.style.display = 'none'; 
        fetch(`https://${GetParentResourceName()}/closeUI`, { method: "POST" });
    });

    document.addEventListener("keydown", (event) => {
        if (event.key === "Escape") {
            container.style.display = 'none'; 
            fetch(`https://${GetParentResourceName()}/closeUI`, { method: "POST" });
        }
    });

    window.addEventListener("message", (event) => {
        if (event.data.type === "showCommands") {
            commandsList.innerHTML = "";
            keybindsList.innerHTML = "";

            // Check if commands exist, otherwise show a no commands message
            if (event.data.commands.length === 0) {
                const noCommandsItem = document.createElement("div");
                noCommandsItem.className = "command-item";
                noCommandsItem.innerHTML = "<em>No commands available</em>";
                commandsList.appendChild(noCommandsItem);
            } else {
                event.data.commands.forEach((cmd) => {
                    const commandItem = document.createElement("div");
                    commandItem.className = "command-item";
                    commandItem.innerHTML = `<strong>${cmd.commandText}</strong> - /${cmd.command}`;
                    commandsList.appendChild(commandItem);
                });
            }

            // Check if keybinds exist, otherwise show a no keybinds message
            if (event.data.keybinds.length === 0) {
                const noKeybindsItem = document.createElement("div");
                noKeybindsItem.className = "command-item";
                noKeybindsItem.innerHTML = "<em>No keybinds available</em>";
                keybindsList.appendChild(noKeybindsItem);
            } else {
                event.data.keybinds.forEach((keybind) => {
                    const keybindItem = document.createElement("div");
                    keybindItem.className = "command-item";
                    keybindItem.innerHTML = `<strong>${keybind.keybindText}</strong> - <span class="keybind">${keybind.keybind}</span>`;
                    keybindsList.appendChild(keybindItem);
                });
            }

            container.style.display = 'block'; 
        } else if (event.data.type === "hideCommands") {
            container.style.display = 'none';
        }
    });

    tabs.forEach((tab) => {
        tab.addEventListener("click", () => {
            if (tab.classList.contains("active")) return;

            tabs.forEach((t) => t.classList.remove("active"));
            tabContents.forEach((content) => content.classList.remove("active"));

            tab.classList.add("active");
            document.getElementById(tab.dataset.tab).classList.add("active");
        });
    });
});