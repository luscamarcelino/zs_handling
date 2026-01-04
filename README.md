# Editor de Handling em tempo real para FIVEM. 

![License](https://img.shields.io/badge/License-Open%20Source-green)
![Status](https://img.shields.io/badge/Status-Stable-blue)
![Price](https://img.shields.io/badge/Price-FREE-orange)

Um editor de handling **em tempo real** avançado para servidores FiveM baseados em QBCore/Qbox. Ajuste cada detalhe da física do veículo enquanto dirige e exporte o resultado final pronto para uso.

---

## ⚠️ AVISO IMPORTANTE / DISCLAIMER

**ESTE PROJETO É DE CÓDIGO ABERTO (OPEN SOURCE) E TOTALMENTE GRATUITO.**

**É ESTRITAMENTE PROIBIDA A VENDA DESTE SCRIPT.**
Você é livre para usar, modificar e compartilhar com a comunidade, desde que mantenha os créditos e a gratuidade. 
Não pague por este recurso. Se você comprou este script, você foi enganado.
---

## ✨ Funcionalidades

* **Edição em Tempo Real:** Sinta as mudanças na física do carro instantaneamente sem precisar reiniciar o script ou spawnar o carro novamente.
* **Interface Organizada:** Separação por categorias (Motor, Tração/Freio, Suspensão, Danos) para fácil navegação.
* **Alta Precisão:** Suporte para 6 casas decimais e proteção para números inteiros (como marchas), evitando quebrar o veículo.
* **Comparação Original:** Mostra o valor original do veículo ao lado do valor editado para referência.
* **Exportação XML:** Gera um arquivo `.meta` completo na pasta do servidor, pronto para copiar e colar no seu `handling.meta`.
* **Reset:** Botão para restaurar os valores originais do veículo caso algo dê errado.
* **Responsivo:** Janela arrastável (Draggable) e tooltips explicativos em cada opção.

## 📦 Instalação

1.  Baixe o repositório e coloque na sua pasta de `resources`.
2.  **IMPORTANTE:** Crie uma pasta chamada `output` dentro da pasta `zs_handlingeditor` (o script precisa dela para salvar os arquivos).
    ```text
    zs_handlingeditor/
    ├── client/
    ├── server/
    ├── web/
    ├── output/  <-- CRIE ESTA PASTA
    └── fxmanifest.lua
    ```
3.  Adicione `ensure zs_handlingeditor` no seu `server.cfg`.

## 🛠️ Como Usar

1.  Entre em um veículo.
2.  Digite o comando `/handling`.
3.  Faça os ajustes desejados nas abas.
4.  Clique em **"Aplicar e Testar"** para sentir a diferença.
5.  Quando estiver satisfeito, clique em **"Exportar XML"**.
6.  O arquivo pronto estará na pasta `zs_handlingeditor/output/`.

## 🤝 Contribuição

Sinta-se à vontade para abrir Issues ou Pull Requests para melhorar o código. A comunidade agradece!
*Discord: @zeusong
---
*Desenvolvido seguindo os padrões do MRI QBOX.*