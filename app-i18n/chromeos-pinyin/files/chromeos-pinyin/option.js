const RimeURL = 'http://127.0.0.1:12345';

document.getElementById("pageSize").onchange = function () {
  window.localStorage.setItem("pageSize", this.value);
}

async function setSchema(schema) {
  let body = "=schema";
  if (schema != "") {
    body += "=" + schema;
  }

  let response = await fetch(
    RimeURL,
    {
      method: "POST",
      body: body
    });
  let text = await response.text();
  if (text == schema) {
    console.log(schema);
    location.reload();
  } else {
    document.getElementById(text).checked = true;
    if (schema != "") {
      alert("切换失败！");
    }
  }
}
document.getElementsByName("schema").forEach(function (ele) {
  ele.onclick = async function handleClick() {
    await setSchema(ele.value);
  }
})

function updateFuzzyCheckBox(options) {
  document.getElementsByName("fuzzy").forEach(function (ele) {
    if (options.includes(ele.value)) {
      ele.checked = true;
    } else {
      ele.checked = false;
    }
  })
}

async function postAndUpdateFuzzy(body) {
  let response = await fetch(
    RimeURL,
    {
      method: "POST",
      body: body
    });
  let text = await response.text();
  updateFuzzyCheckBox(text.split("\n"));
}

async function addFuzzy(option) {
  let body = "=algebra+" + option;
  await postAndUpdateFuzzy(body);
  
}
async function removeFuzzy(option) {
  let body = "=algebra-" + option;
  await postAndUpdateFuzzy(body);
}
async function getFuzzy() {
  let body = "=algebra";
  await postAndUpdateFuzzy(body);
}
document.getElementsByName("fuzzy").forEach(function (ele) {
  ele.onclick = async function handleClick() {
    if (ele.checked) {
      await addFuzzy(ele.value);
    } else {
      await removeFuzzy(ele.value);
    }
  }
})


document.getElementById("pageSize").value = window.localStorage.getItem("pageSize") || 8;

setSchema("");
getFuzzy();
