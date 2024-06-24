---@diagnostic disable: undefined-global, lowercase-global
local physics = require("physics")
physics.start();
physics.setDrawMode("normal");

math.randomseed(os.time())

local grupoBackGround = display.newGroup()
local main = display.newGroup()
local uI = display.newGroup()

local bg = display.newImageRect(grupoBackGround, "./images/underwater.png", 768 * 1.7, 192 * 1.7);
bg.x = display.contentCenterX
bg.y = display.contentCenterY



local bola = display.newImage(main, "./images/mergulhador.png", display.contentCenterX - 50, display.contentCenterY, 25);
bola.myName = "player"
physics.addBody(bola, "dynamic", { radius = 25 })
bola.gravityScale = 0

local peixe1 = display.newImageRect(main, "./images/peixe1.png", 48 * 1.3, 48 * 1.3)
physics.addBody(peixe1, "dynamic", { radius = 10, isSensor = true })
peixe1.gravityScale = 0
peixe1.x = -100
peixe1.y = 300
peixe1.myName = "peixe"

local peixe2 = display.newImageRect(main, "./images/peixe2.png", 48 * 1.3, 48 * 1.3)
physics.addBody(peixe2, "dynamic", { radius = 10, isSensor = true })
peixe2.gravityScale = 0
peixe2.x = 250
peixe2.y = 300
peixe2.myName = "peixe"

local peixe3 = display.newImageRect(main, "./images/peixe3.png", 48 * 1.3, 48 * 1.3)
physics.addBody(peixe3, "dynamic", { radius = 10, isSensor = true })
peixe3.gravityScale = 0
peixe3.x = 75
peixe3.y = 300
peixe3.myName = "peixe"

local audioBg = audio.loadStream("./audio/musicgame.ogg");
audio.reserveChannels(1);
audio.setVolume(0.5, { channel = 1 });
audio.play(audioBg, { channel = 1, loops = -1 })
local audioLixo = audio.loadSound("./audio/coin.wav");
local audioBolha = audio.loadSound("./audio/swim.wav");
local audioPeixe = audio.loadSound("./audio/yoshispit.wav");
audio.reserveChannels(2, 3, 4)
audio.setVolume(0.5, { channel = 2 });
audio.setVolume(0.5, { channel = 3 });
audio.setVolume(0.5, { channel = 4 });

local morte = false
local bolhaTabela = {}
local lixoTabela = {}
local oxigenio = 100
local pontuacao = 0
local contador = 3

local oxigenioTexto = display.newText(uI, "Oxigênio: " .. oxigenio, display.contentCenterX - 200, 20, native.systemFont,
    20);
local pontuacaoTexto = display.newText(uI, "Pontuação: " .. pontuacao, display.contentCenterX + 150, 20,
    native.systemFont, 20)

local botaoD = display.newImageRect(uI, "./images/botao1.png", 360 * 0.2, 360 * 0.2);
botaoD.x = 500
botaoD.y = 280

local botaoE = display.newImageRect(uI, "./images/botao1.png", 360 * 0.2, 360 * 0.2);
botaoE.rotation = 180
botaoE.x = 380
botaoE.y = 280

local botaoB = display.newImageRect(uI, "./images/botao1.png", 360 * 0.2, 360 * 0.2);
botaoB.rotation = 90
botaoB.x = 440
botaoB.y = 280

local botaoC = display.newImageRect(uI, "./images/botao1.png", 360 * 0.2, 360 * 0.2);
botaoC.rotation = 270
botaoC.x = 440
botaoC.y = 220

local function moveCima()
    if bola.y - bola.height * 0.5 > 0 then
        bola.y = bola.y - 2
    end
end

local function moveBaixo()
    if bola.y + bola.height * 0.5 < display.contentHeight then
        bola.y = bola.y + 2
    end
end

local function moveEsq()
    if (bola.x > -100) then -- Limite esquerdo
        bola.x = bola.x - 2
    end
end

local function moveDir()
    if (bola.x < 530) then -- Limite direito
        bola.x = bola.x + 2
    end
end

local function moverPeixe(obj)
    transition.to(obj, { time = 2000, x = 100, delta = true })
    transition.to(obj, { delay = 2000, time = 500, xScale = -1 })
    transition.to(obj, { x = -100, delay = 2500, time = 2000, delta = true })
    transition.to(obj, { delay = 4500, time = 500, xScale = 1 })
end

local function moverTudo()
    moverPeixe(peixe1)
    moverPeixe(peixe2)
    moverPeixe(peixe3)
end
moverTudo()

local loop = timer.performWithDelay(5000, moverTudo, -1);

local function criaBolha()
    local novaBolha = display.newImageRect("./images/bolha.png", 256 * 0.17, 144 * 0.17)
    physics.addBody(novaBolha, "dynamic", { radius = 10, isSensor = true })
    novaBolha.gravityScale = -0.017
    novaBolha.myName = "bolha"
    novaBolha.x = math.random(display.screenOriginX, display.actualContentWidth)
    novaBolha.y = 350
end

local function loopBolha()
    criaBolha()
    for i = #bolhaTabela, 1, -1 do
        local essaBolha = bolhaTabela[i]
        if ((essaBolha.x < -300) or (essaBolha.x > display.contentWidth + 300) or (essaBolha.y < -300) or (essaBolha.y > display.contentHeight + 300)) then
            display.remove(essaBolha)
            table.remove(bolhaTabela, i)
        end
    end
end

local function criaLixo()
    local escolhaLixo = math.random(4)
    local enderecoL
    local alturaL
    local larguraL

    if (escolhaLixo == 1) then
        enderecoL = "./images/garbagebag1.png"
        alturaL = 21 * 1.5
        larguraL = 18 * 1.5
    elseif (escolhaLixo == 2) then
        enderecoL = "./images/garbagebag2.png"
        alturaL = 15 * 1.5
        larguraL = 19 * 1.5
    elseif (escolhaLixo == 3) then
        enderecoL = "./images/garbagebagsmall1.png"
        alturaL = 11 * 1.5
        larguraL = 12 * 1.5
    elseif (escolhaLixo == 4) then
        enderecoL = "./images/garbagebagsmall2.png"
        alturaL = 10 * 1.5
        larguraL = 8 * 1.5
    end
    local novoLixo = display.newImageRect(enderecoL, larguraL, alturaL)
    physics.addBody(novoLixo, "dynamic", { isSensor = true })
    novoLixo.gravityScale = 0.03
    table.insert(lixoTabela, novoLixo);
    novoLixo.myName = "lixo"

    novoLixo.x = math.random(display.screenOriginX, display.actualContentWidth)
    novoLixo.y = -20
end

function atualizaTexto()
    oxigenioTexto.text = "Oxigênio" .. oxigenio
    pontuacaoTexto.text = "Pontuação: " .. pontuacao
end

function loopLixo()
    criaLixo()
    for i = #lixoTabela, 1, -1 do
        local esseLixo = lixoTabela[i]
        if ((esseLixo.x < -300) or (esseLixo.x > display.contentWidth + 300) or (esseLixo.y < -300) or (esseLixo.y > display.contentHeight + 300)) then
            display.remove(esseLixo)
            table.remove(lixoTabela, i)
        end
    end
end

local function perdaOxigenio()
    if (morte == false) then
        oxigenio = oxigenio - 1

        if oxigenio == 0 then
            morte = true
            display.newText(uI, "GAME OVER!", display.contentCenterX, 120, native.systemFont,
                60);
            display.remove(bola)
            display.remove(peixe1)
            display.remove(peixe2)
            display.remove(peixe3)
            display.remove(botaoC)
            display.remove(botaoB)
            display.remove(botaoE)
            display.remove(botaoD)
            display.remove(oxigenioTexto)
            display.remove(pontuacaoTexto)
        end
    end
end

local function onCollision(event)
    local fase = event.phase
    if (fase == "began") then
        local obj1 = event.object1
        local obj2 = event.object2

        if (((obj1.myName == "bolha") and (obj2.myName == "player")) or ((obj1.myName == "player") and (obj2.myName == "bolha"))) then
            if obj1.myName == "bolha" then
                display.remove(obj1)
            else
                display.remove(obj2)
            end
            audio.play(audioBolha, { channel = 3 })
            for i = #bolhaTabela, 1, -1 do
                if ((bolhaTabela[i] == obj1) or (bolhaTabela[i] == obj2)) then
                    table.remove(bolhaTabela, i)

                    break
                end
            end
            oxigenio = oxigenio + 10

            atualizaTexto()
        elseif (((obj1.myName == "lixo") and (obj2.myName == "player")) or ((obj1.myName == "player") and (obj2.myName == "lixo"))) then
            pontuacao = pontuacao + 100
            if obj1.myName == "lixo" then
                display.remove(obj1)
            else
                display.remove(obj2)
            end
            audio.play(audioLixo, { channel = 2 })
            atualizaTexto()
        elseif (((obj1.myName == "lixo") and (obj2.myName == "peixe")) or ((obj1.myName == "peixe") and (obj2.myName == "lixo"))) then
            display.remove(obj1)
            display.remove(obj2)
            contador = contador - 1
            audio.play(audioPeixe, { channel = 4 })
            if contador == 0 then
                display.newText(uI, "GAME OVER!", display.contentCenterX, 120, native.systemFont,
                    60);
                display.remove(bola)
                display.remove(peixe1)
                display.remove(peixe2)
                display.remove(peixe3)
                display.remove(botaoC)
                display.remove(botaoB)
                display.remove(botaoE)
                display.remove(botaoD)
                display.remove(oxigenioTexto)
                display.remove(pontuacaoTexto)
            end
        end
    end
end

local function atualizaTextoOx()
    atualizaTexto()
end

local lixoLoop = timer.performWithDelay(3000, criaLixo, -1)
local loopBolha = timer.performWithDelay(3000, criaBolha, -1)
local perdaOxigenio = timer.performWithDelay(800, perdaOxigenio, -1)
local perdaOxigenioText = timer.performWithDelay(1, atualizaTextoOx, -1)

botaoC:addEventListener("touch", moveCima)
botaoB:addEventListener("touch", moveBaixo)
botaoE:addEventListener("touch", moveEsq)
botaoD:addEventListener("touch", moveDir)
peixe1:addEventListener("enterFrame", moverPeixe)
Runtime:addEventListener("collision", onCollision)
