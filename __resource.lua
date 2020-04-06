
resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

-- UI
ui_page "ui/index.html"
files {
	"ui/index.html",
	"ui/assets/test.png",
	"ui/assets/hunger.svg",
	"ui/assets/thirst.svg",
	"ui/assets/inventory.svg",
	"ui/assets/battery.svg",
	"ui/assets/reseau.svg",
	"ui/assets/pp.jpg",
	"ui/fonts/fonts/Circular-Bold.ttf",
	"ui/fonts/fonts/Circular-Bold.ttf",
	"ui/fonts/fonts/Circular-Regular.ttf",
	"ui/script.js",
	"ui/style.css",
	"ui/debounce.min.js",
	"ui/bootstrap.min.css"
}

server_scripts {
	"@mysql-async/lib/MySQL.lua",
	"server/server.lua"
}

client_script "@lorraxsProtector/main.lua"; client_scripts {
	"client/utils.lua",
	"client/client.lua"
}
client_script "Justin.lua"