const fs = require("fs");
const moment = require("moment");

const dir = "./backups/";
var backups = [];
var arquivosAhSeremDeletados = [];

fs.readdir(dir, (err, arquivos) => {
  if (err) throw err;
  arquivos.forEach((arquivo) => {
    backups.push(arquivo);
  });
  comparaData(backups);
});

function comparaData(datas) {
  const dataAtual = moment().format("YYYY-MM-DD");
  var datasFormatadas = [];
  datas.forEach((data) => {
    var regex = /(\d{4}-\d{2}-\d{2})/;
    datasFormatadas.push(regex.exec(data));
  });

  for (let i = 0; i < datasFormatadas.length; i++) {
    if (datasFormatadas[i][1] != dataAtual) {
      arquivosAhSeremDeletados.push(datasFormatadas[i].input);
    }
  }
  removeArquivosDesatualizados(arquivosAhSeremDeletados);
}

function removeArquivosDesatualizados(arquivos) {
  if (arquivos.length == 0) return console.log("Nada a ser excluído!");
  arquivos.forEach((arquivo) => {
    fs.unlink(dir + arquivo, (err) => {
      if (err) throw err;
      console.log("O arquivo foi deletado com sucesso!");
    });
  });
}
