/**
 * @author felixturner / http://airtight.cc/
 *
 * Dot Matrix Shader - Renders texture as a grid of dots like an LED display
 * TODO - use a single color for dots based on average of pixels
 *
 * spacing: distance between dots in px
 * size: radius of dots in px
 * blur: blur radius of dots in px
 */

 THREE.DotMatrixShader = {

	uniforms: {

		"tDiffuse": { type: "t", value: null },
		"spacing":     { type: "f", value: 10.0 },
		"size":     { type: "f", value: 4.0 },
		"blur":     { type: "f", value: 4.0 }

	},

	vertexShader: [

	"varying vec2 vUv;",

	"void main() {",

	"vUv = uv;",
	"gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );",

	"}"

	].join("\n"),

	fragmentShader: [

	"uniform sampler2D tDiffuse;",
	"uniform float spacing;",
	"uniform float size;",
	"uniform float blur;",

	"varying vec2 vUv;",

	"void main() {",

		"vec2 p = vUv;",
		"vec4 color = texture2D(tDiffuse, p);",

		"vec2 pos = mod(gl_FragCoord.xy, vec2(spacing)) - vec2(spacing/2.0);",
		"float dist_squared = dot(pos, pos);",
		"gl_FragColor = mix(color, vec4(0.0), smoothstep(size, size + blur, dist_squared));",

		"}"

		].join("\n")

	};
