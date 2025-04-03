let toggle = document.querySelector(".toggle-ad");
let navigation = document.querySelector(".menu-ad");
let main = document.querySelector(".layout-content-ad");

toggle.onclick = function () {
  navigation.classList.toggle("active");
  main.classList.toggle("active");
};
