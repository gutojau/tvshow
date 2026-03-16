# tvshow
ESTRUTURA PARA MIDIA INDOOR
=====================================================
  ODONTOLOGIA BERRO — MÍDIA INDOOR
  Guia de Instalação e Uso
=====================================================

ESTRUTURA DO PEN DRIVE:
  index.html               ← página principal
  playlist.js              ← gerado pelo gerar_manifest.bat/sh
  manifest.json            ← gerado pelo gerar_manifest.bat/sh
  odontologia-berro.png    ← logomarca
  gerar_manifest.bat       ← gerador de playlist (Windows)
  gerar_manifest.sh        ← gerador de playlist (Mac/Linux)
  programacao/
      video1.mp4
      video2.mp4
      ...

-----------------------------------------------------
PASSO A PASSO — PRIMEIRA VEZ
-----------------------------------------------------
1. Copie todos os arquivos acima para o pen drive
2. Coloque os vídeos MP4 dentro da pasta "programacao"
3. Execute o gerador de playlist:
     Windows → duplo clique em gerar_manifest.bat
     Mac/Linux → Terminal: bash gerar_manifest.sh
4. Confirme que playlist.js foi criado na raiz
5. Conecte o pen drive na Smart TV
6. Abra o navegador da TV e navegue até index.html
7. Toque na tela para iniciar (libera o áudio)
8. Ative tela cheia pelo menu da TV

-----------------------------------------------------
ADICIONANDO OU REMOVENDO VÍDEOS
-----------------------------------------------------
1. Copie/remova os arquivos da pasta "programacao"
2. Execute gerar_manifest.bat (ou .sh) novamente
3. O index.html atualizará automaticamente

-----------------------------------------------------
COMO FUNCIONA A DETECÇÃO DE VÍDEOS (cascata)
-----------------------------------------------------
O player tenta as seguintes fontes em ordem:

  1. playlist.js    → funciona em file:// (pen drive direto)
  2. manifest.json  → funciona com servidor HTTP
  3. Dir listing    → Python http.server / Apache / Nginx
  4. CONFIG.videoFiles → lista manual no index.html

Se você rodou o gerar_manifest.bat, a estratégia 1
será usada e os vídeos carregarão sem servidor.

-----------------------------------------------------
NOTÍCIAS (ticker inferior)
-----------------------------------------------------
- Exige conexão Wi-Fi ou cabo na TV
- Atualiza a cada 15 minutos automaticamente
- Usa 3 proxies em cascata (se um falhar, tenta outro)
- Fontes: BBC Brasil, G1, UOL, Folha
- Para mudar as fontes, edite CONFIG.rssFeeds no index.html

-----------------------------------------------------
CLIMA
-----------------------------------------------------
- Exige conexão Wi-Fi ou cabo na TV
- API Open-Meteo (gratuita, sem cadastro)
- Atualiza a cada 10 minutos
- Para mudar a cidade, edite CONFIG.location no index.html
  Exemplo São Paulo: lat: -23.5505, lon: -46.6333

-----------------------------------------------------
BARRA DE STATUS (debug)
-----------------------------------------------------
- Oculta por padrão
- Para ativar: abra index.html em editor de texto,
  localize "#status{display:none}" e troque por
  "#status{display:block}"
- Mostra qual vídeo está tocando e erros em tempo real

-----------------------------------------------------
ÁUDIO
-----------------------------------------------------
Browsers modernos bloqueiam autoplay com áudio.
Por isso aparece uma tela "Toque para iniciar".
Após o primeiro toque, o áudio funciona normalmente
em todos os vídeos seguintes sem nova interação.

-----------------------------------------------------
FORMATOS DE VÍDEO SUPORTADOS
-----------------------------------------------------
  .mp4 (H.264)  ← recomendado, universal
  .mov          ← compatível na maioria das TVs
  .webm         ← boa compressão
  .m4v          ← compatível
  .mkv          ← suporte variável por TV

Recomendação: MP4 H.264, 1920x1080, 8-15 Mbps

-----------------------------------------------------
IOS / iPHONE / iPAD
-----------------------------------------------------
O gerar_manifest.bat/.sh não roda em iOS.
Solução: gere o playlist.js no Windows ou Mac antes
de copiar os arquivos para o pen drive.

-----------------------------------------------------
INTERNET NÃO DISPONÍVEL
-----------------------------------------------------
Vídeos: funcionam 100% offline
Clima:  exibe "—°C" sem travar
Notícias: mantém o último cache ou exibe mensagem

=====================================================
