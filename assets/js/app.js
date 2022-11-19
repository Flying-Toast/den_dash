const rainbowText = "Hello!";
let fmt = "";
const rainbow = ["red", "orange", "yellow", "lime", "skyblue", "magenta"];
let styles = [];
let idx = 0;
for (const i of rainbowText) {
	fmt += "%c" + i;
	styles.push(`font-size: 400%; background-color: black; color: ${rainbow[idx++ % rainbow.length]};`);
}
console.log(fmt, ...styles);
console.log("%chttps://github.com/Flying-Toast/den_dash", "font-size: 200%;");
