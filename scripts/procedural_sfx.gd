class_name ProceduralSFX

# Biblioteca estática de sons procedurais
# Todos os sons são sintetizados em runtime com funções matemáticas.
# Retornam AudioStreamWAV (mono, 22050 Hz, 16-bit) prontos para tocar.

const MIX_RATE := 22050

static func _make_wav(samples: PackedFloat32Array) -> AudioStreamWAV:
	# Converte float32 normalizado (-1..1) para PCM 16-bit little-endian
	var wav      := AudioStreamWAV.new()
	wav.mix_rate = MIX_RATE
	wav.stereo   = false
	wav.format   = AudioStreamWAV.FORMAT_16_BITS
	var n        := samples.size()
	var b        := PackedByteArray()
	b.resize(n * 2)
	for i in n:
		var v      := int(clamp(samples[i], -1.0, 1.0) * 32767.0)
		b[i * 2]   = v & 0xFF          # byte menos significativo
		b[i * 2 + 1] = (v >> 8) & 0xFF # byte mais significativo
	wav.data = b
	return wav


static func footstep_sand() -> AudioStreamWAV:
	# Passo na areia, ruído branco filtrado por passa-baixo + sub-grave suave.
	# rng.randomize() = seed diferente a cada chamada → 4 variações distintas no player.
	var dur  := 0.085
	var n    := int(MIX_RATE * dur)
	var s    := PackedFloat32Array()
	s.resize(n)
	var rng  := RandomNumberGenerator.new()
	rng.randomize()

	var prev := 0.0
	for i in n:
		var t    := float(i) / float(MIX_RATE)
		var env  := exp(-t * 32.0)     # envelope muito curto (crunch seco)
		var w    := rng.randf_range(-1.0, 1.0)
		# Filtro IIR passa-baixo simples: 52% novo + 48% anterior
		var lp   := w * 0.48 + prev * 0.52
		prev      = lp
		var body := sin(TAU * 90.0 * t) * 0.30  # corpo grave (thud de areia comprimida)
		s[i] = (lp * 0.55 + body) * env * 0.72
	return _make_wav(s)


static func item_pickup() -> AudioStreamWAV:
	# Coleta de item, chirp ascendente (freq 380→760 Hz) com segundo harmônico.
	# Soa como "tchim!" de moeda, mas mais orgânico.
	var dur   := 0.18
	var n     := int(MIX_RATE * dur)
	var s     := PackedFloat32Array()
	s.resize(n)
	var phase := 0.0

	for i in n:
		var t   := float(i) / float(MIX_RATE)
		var env := exp(-t * 9.5)
		# Chirp: frequência aumenta linearmente com o tempo (380→760 Hz)
		var freq := 380.0 + 380.0 * (t / dur)
		phase    += TAU * freq / float(MIX_RATE)
		s[i] = (sin(phase) * 0.72 + sin(phase * 2.0) * 0.14) * env * 0.58
	return _make_wav(s)


static func checkpoint_ping() -> AudioStreamWAV:
	# Jingle de checkpoint, dois tons sobrepostos: Dó5 (523 Hz) e Mi5 (659 Hz).
	# O Mi5 começa 130ms depois para criar o efeito de "acorde em arpejo".
	var dur := 0.38
	var n   := int(MIX_RATE * dur)
	var s   := PackedFloat32Array()
	s.resize(n)

	for i in n:
		var t  := float(i) / float(MIX_RATE)
		var s1 := 0.0
		var s2 := 0.0
		if t < 0.22:
			s1 = sin(TAU * 523.0 * t) * exp(-t * 7.0) * 0.65
		if t >= 0.13:
			var t2 := t - 0.13
			s2 = sin(TAU * 659.0 * t2) * exp(-t2 * 7.0) * 0.65
		s[i] = clampf(s1 + s2, -1.0, 1.0) * 0.75
	return _make_wav(s)


static func music_box_melody() -> AudioStreamWAV:
	# Melodia da caixinha de música, escala Lá menor ascendente-descendente.
	# Cada nota tem 3 harmônicos (fundamental + 2ª + 3ª) com decaimento exponencial,
	# simulando o timbre metálico de uma caixinha de música real.
	var freqs: Array[float] = [440.0, 523.25, 659.25, 880.0, 659.25, 523.25, 440.0]
	var step  := 0.38   # duração entre ataques de nota (segundos)
	var tail  := 0.9    # cauda de ressonância após a última nota
	var total := freqs.size() * step + tail
	var n     := int(MIX_RATE * total)
	var s     := PackedFloat32Array()
	s.resize(n)
	for ni in freqs.size():
		var onset := int(ni * step * MIX_RATE)
		var freq  := freqs[ni]
		for j in int(MIX_RATE * (tail + step)):
			var idx := onset + j
			if idx >= n:
				break
			var t  := float(j) / float(MIX_RATE)
			var e  := exp(-t * 8.5)
			s[idx] += (sin(TAU * freq * t) * 0.68
					 + sin(TAU * freq * 2.0 * t) * 0.20  # 2ª harmônica (oitava)
					 + sin(TAU * freq * 3.0 * t) * 0.07) * e * 0.52  # 3ª harmônica
	return _make_wav(s)


static func thunder() -> AudioStreamWAV:
	# Trovão, combinação de ruído HP (estalo inicial) + ruído LP modulado (trovão grave).
	# rng.randomize() = som diferente a cada raio (variação natural).
	var dur   := 2.0
	var n     := int(MIX_RATE * dur)
	var s     := PackedFloat32Array()
	s.resize(n)
	var rng   := RandomNumberGenerator.new()
	rng.randomize()
	var prev1 := 0.0
	var prev2 := 0.0
	for i in n:
		var t     := float(i) / float(MIX_RATE)
		var raw   := rng.randf_range(-1.0, 1.0)
		# Passa-alto (HP): realça frequências altas → estalo do raio
		var hp    := raw * 0.55 + prev1 * 0.45
		prev1      = raw
		var crack := hp * exp(-t * 18.0) * 0.60
		# Passa-baixo (LP): frequências graves moduladas por seno → estrondo
		var lp    := raw * 0.06 + prev2 * 0.94
		prev2      = lp
		var rumble := lp * (0.5 + 0.5 * sin(TAU * 52.0 * t)) * exp(-t * 1.8) * 0.75
		s[i] = clampf(crack + rumble, -1.0, 1.0) * 0.85
	return _make_wav(s)


static func storm_loop() -> AudioStreamWAV:
	# Loop de tempestade, vento em loop determinístico (seed fixa = 7391).
	# Seed fixa garante que o ponto de loop (sample 0 = sample N) tenha valor idêntico,
	# eliminando o click ao repetir o AudioStreamWAV.LOOP_FORWARD.
	# Dois filtros LP com larguras diferentes criam camadas de vento (agudo + grave).
	var dur  := 3.0
	var n    := int(MIX_RATE * dur)
	var s    := PackedFloat32Array()
	s.resize(n)
	var rng  := RandomNumberGenerator.new()
	rng.seed  = 7391  # seed fixa → loop sem click
	var lp1  := 0.0
	var lp2  := 0.0
	for i in n:
		var t        := float(i) / float(MIX_RATE)
		var raw      := rng.randf_range(-1.0, 1.0)
		# LP largo (0.30/0.70) = camada de vento médio
		lp1           = raw * 0.30 + lp1 * 0.70
		# LP estreito (0.04/0.96) = camada grave do vento
		lp2           = raw * 0.04 + lp2 * 0.96
		# Modulação LFO duplo = rafaga de vento irregular (0.25 Hz + 0.11 Hz)
		var wind_mod := 0.6 + 0.4 * sin(TAU * 0.25 * t) + 0.2 * sin(TAU * 0.11 * t)
		s[i] = clampf(lp1 * 0.40 + lp2 * wind_mod * 1.20, -1.0, 1.0) * 0.55
	var wav := _make_wav(s)
	wav.loop_mode  = AudioStreamWAV.LOOP_FORWARD
	wav.loop_begin = 0
	wav.loop_end   = n - 1
	return wav


static func ocean_loop() -> AudioStreamWAV:
	# Loop de ondas do mar, ruído LP muito suave com dois "swells" sobrepostos.
	# Seed fixa = 1337 → mesmo princípio do storm_loop (sem click no ponto de loop).
	# Os dois senos de baixa frequência (0.50 Hz + 0.32 Hz desfasados) simulam
	# ondas que chegam em ritmos diferentes, como na natureza.
	var dur  := 4.0
	var n    := int(MIX_RATE * dur)
	var s    := PackedFloat32Array()
	s.resize(n)
	var rng  := RandomNumberGenerator.new()
	rng.seed  = 1337
	var lp   := 0.0
	for i in n:
		var t      := float(i) / float(MIX_RATE)
		var raw    := rng.randf_range(-1.0, 1.0)
		# LP muito estreito (0.03/0.97) = ruído suavíssimo (shhhh do mar)
		lp          = raw * 0.03 + lp * 0.97
		# Dois swells: maxf(0,sin) corta a metade negativa → som de "chegada" da onda
		var swell  := maxf(0.0, sin(TAU * 0.50 * t))
		var swell2 := maxf(0.0, sin(TAU * 0.32 * t + 1.2))
		s[i] = lp * (0.12 + (swell + swell2 * 0.6) * 0.38)
	var wav := _make_wav(s)
	wav.loop_mode  = AudioStreamWAV.LOOP_FORWARD
	wav.loop_begin = 0
	wav.loop_end   = n - 1
	return wav


static func sand_fill() -> AudioStreamWAV:
	# Pá tapando buraco de areia, ruído LP com ataque rápido + thud grave.
	# rng.randomize() = som ligeiramente diferente a cada interação.
	# Envelope: `(1-exp(-45t)) * exp(-11t)` = ataque instantâneo, decaimento médio.
	var dur  := 0.24
	var n    := int(MIX_RATE * dur)
	var s    := PackedFloat32Array()
	s.resize(n)
	var rng  := RandomNumberGenerator.new()
	rng.randomize()

	var prev := 0.0
	for i in n:
		var t   := float(i) / float(MIX_RATE)
		# Envelope: subida rápida (45) + decaimento médio (11) → "flap" de areia
		var env := (1.0 - exp(-t * 45.0)) * exp(-t * 11.0)
		var w   := rng.randf_range(-1.0, 1.0)
		var lp  := w * 0.38 + prev * 0.62
		prev     = lp
		var thud := sin(TAU * 68.0 * t) * exp(-t * 20.0) * 0.38  # pancada grave
		s[i] = (lp * 0.62 + thud) * env * 0.68
	return _make_wav(s)
