extends GutTest

# Testa geração procedural de áudio (ProceduralSFX)
# Todos os métodos são estáticos — sem dependência de cena.

func test_footstep_sand_retorna_wav() -> void:
	var wav := ProceduralSFX.footstep_sand()
	assert_not_null(wav, "footstep_sand() não deve retornar null")
	assert_true(wav is AudioStreamWAV, "deve ser AudioStreamWAV")

func test_footstep_sand_tem_dados() -> void:
	var wav := ProceduralSFX.footstep_sand()
	assert_true(wav.data.size() > 0, "WAV não pode ter dados vazios")

func test_footstep_sand_variacao() -> void:
	# Sem seed fixa → cada chamada gera variação diferente
	var wav1 := ProceduralSFX.footstep_sand()
	var wav2 := ProceduralSFX.footstep_sand()
	assert_ne(wav1.data, wav2.data, "footstep deve variar a cada chamada")

func test_item_pickup_retorna_wav() -> void:
	var wav := ProceduralSFX.item_pickup()
	assert_not_null(wav)
	assert_true(wav is AudioStreamWAV)

func test_item_pickup_tem_dados() -> void:
	var wav := ProceduralSFX.item_pickup()
	assert_true(wav.data.size() > 0)

func test_checkpoint_ping_retorna_wav() -> void:
	var wav := ProceduralSFX.checkpoint_ping()
	assert_not_null(wav)
	assert_true(wav is AudioStreamWAV)

func test_checkpoint_ping_tem_dados() -> void:
	var wav := ProceduralSFX.checkpoint_ping()
	assert_true(wav.data.size() > 0)

func test_music_box_melody_retorna_wav() -> void:
	var wav := ProceduralSFX.music_box_melody()
	assert_not_null(wav)
	assert_true(wav is AudioStreamWAV)

func test_music_box_melody_tem_dados() -> void:
	var wav := ProceduralSFX.music_box_melody()
	assert_true(wav.data.size() > 0)

func test_thunder_retorna_wav() -> void:
	var wav := ProceduralSFX.thunder()
	assert_not_null(wav)
	assert_true(wav is AudioStreamWAV)

func test_thunder_tem_dados() -> void:
	var wav := ProceduralSFX.thunder()
	assert_true(wav.data.size() > 0)

func test_sand_fill_retorna_wav() -> void:
	var wav := ProceduralSFX.sand_fill()
	assert_not_null(wav)
	assert_true(wav is AudioStreamWAV)

func test_sand_fill_tem_dados() -> void:
	var wav := ProceduralSFX.sand_fill()
	assert_true(wav.data.size() > 0)

# ── Loops: devem ter seed fixa → determinísticos ──────────────────────────────

func test_ocean_loop_e_determinístico() -> void:
	var wav1 := ProceduralSFX.ocean_loop()
	var wav2 := ProceduralSFX.ocean_loop()
	assert_eq(wav1.data, wav2.data, "ocean_loop com seed fixa deve ser idêntico")

func test_storm_loop_e_determinístico() -> void:
	var wav1 := ProceduralSFX.storm_loop()
	var wav2 := ProceduralSFX.storm_loop()
	assert_eq(wav1.data, wav2.data, "storm_loop com seed fixa deve ser idêntico")

func test_ocean_loop_modo_loop() -> void:
	var wav := ProceduralSFX.ocean_loop()
	assert_eq(wav.loop_mode, AudioStreamWAV.LOOP_FORWARD,
			"ocean_loop deve ter LOOP_FORWARD")

func test_storm_loop_modo_loop() -> void:
	var wav := ProceduralSFX.storm_loop()
	assert_eq(wav.loop_mode, AudioStreamWAV.LOOP_FORWARD,
			"storm_loop deve ter LOOP_FORWARD")

func test_ocean_loop_loop_begin_zero() -> void:
	var wav := ProceduralSFX.ocean_loop()
	assert_eq(wav.loop_begin, 0)

func test_storm_loop_loop_begin_zero() -> void:
	var wav := ProceduralSFX.storm_loop()
	assert_eq(wav.loop_begin, 0)

func test_mix_rate_padrao() -> void:
	# Todos os WAVs devem usar MIX_RATE = 22050
	var wav := ProceduralSFX.item_pickup()
	assert_eq(wav.mix_rate, 22050)

func test_formato_16_bits() -> void:
	var wav := ProceduralSFX.footstep_sand()
	assert_eq(wav.format, AudioStreamWAV.FORMAT_16_BITS)

func test_mono() -> void:
	var wav := ProceduralSFX.footstep_sand()
	assert_false(wav.stereo, "som deve ser mono (stereo = false)")
