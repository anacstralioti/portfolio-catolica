extends Node

# Singleton global (Autoload), persiste entre todas as trocas de cena.
# O Godot destrói e recria a árvore de nós a cada change_scene_to_file(),
# portanto qualquer dado que precise sobreviver à transição fica aqui.

var next_phase_number  := 1                  # qual fase carregar em phase_intro
var next_phase_name    := "Ecos do Silêncio" # nome exibido na tela de introdução
var current_save_slot  := 1                  # slot escolhido pelo jogador (1–3)

# Dados da foto coletada armazenados aqui para que o jogador possa
# reabrir o overlay pelo inventário mesmo após sair da cena do objeto.
var photo_texture: Texture2D = null
var photo_caption: String    = ""

# Flag da carta, basta saber se foi coletada; o conteúdo está na cena do overlay.
var has_diary: bool = false
