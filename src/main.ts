import {
  Color,
  Mesh,
  PerspectiveCamera,
  PlaneGeometry,
  Scene,
  ShaderMaterial,
  Texture,
  TextureLoader,
  Vector2,
  WebGLRenderer,
} from "three";
import "./style.css";
import { getProject, types, val } from "@theatre/core";
import studio from "@theatre/studio";
import projectState from "./project-state.json";
// import { OrbitControls } from "three-stdlib";
// @ts-ignore
import VertexShader from "./shader/blur.vert";
// @ts-ignore
import FragmentShader from "./shader/blur.frag";
import { FFmpeg } from "@ffmpeg/ffmpeg";
import { fetchFile, toBlobURL } from "@ffmpeg/util";

studio.initialize();

const init = async () => {
  /**
   * Camera
   */

  const camera = new PerspectiveCamera(
    70,
    window.innerWidth / window.innerHeight,
    0.1,
    200
  );

  camera.position.z = 50;

  /**
   * Scene
   */

  const scene = new Scene();
  scene.background = new Color("black");

  const textureLoader = new TextureLoader();

  const asyncTextureLoader = async (url: string): Promise<Texture> =>
    await new Promise((resolve) => {
      textureLoader.load(url, (text) => {
        resolve(text);
      });
    });

  const desktopAlphaTexture = await asyncTextureLoader("/desktop-alpha.png");
  const mobileAlphaTexture = await asyncTextureLoader("/mobile-alpha.png");

  const data = [
    {
      src: "/apecoin2.png",
      size: 15,
      position: [0, 0, -5],
      color: "#000",
      alphaMap: desktopAlphaTexture,
    },
    {
      src: "/erthos2.png",
      size: 10,
      position: [-35, 20, 5],
      color: "#fff",
      alphaMap: desktopAlphaTexture,
    },
    {
      src: "/merlin-footer2.png",
      size: 10,
      position: [25, -10, 15],
      color: "#ffa61e",
      alphaMap: desktopAlphaTexture,
    },
    {
      src: "/merlin-mobile2.png",
      size: 10,
      position: [-15, -5, 5],
      color: "#324434",
      alphaMap: mobileAlphaTexture,
    },
    {
      src: "/summoner2.png",
      size: 10,
      position: [15, 13, 15],
      color: "#000",
      alphaMap: desktopAlphaTexture,
    },
    {
      src: "/works-mobile2.png",
      size: 10,
      position: [-30, -13, 15],
      color: "#f5e31a",
      alphaMap: mobileAlphaTexture,
    },
  ];

  /**
   * Renderer
   */

  const renderer = new WebGLRenderer({
    antialias: true,
    preserveDrawingBuffer: true,
  });

  renderer.setSize(window.innerWidth, window.innerHeight);
  renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
  renderer.render(scene, camera);

  document.body.appendChild(renderer.domElement);

  // new OrbitControls(camera, renderer.domElement);

  /**
   * Update the screen
   */
  function tick(): void {
    renderer.render(scene, camera);

    window.requestAnimationFrame(tick);
  }

  tick();

  /**
   * Handle `resize` events
   */
  window.addEventListener(
    "resize",
    function () {
      camera.aspect = window.innerWidth / window.innerHeight;
      camera.updateProjectionMatrix();

      renderer.setSize(window.innerWidth, window.innerHeight);
      renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
    },
    false
  );

  // #region Theatre.js Studio

  // Create a project for the animation
  const project = getProject("THREE.js x Theatre.js", { state: projectState });
  // Play the animation on repeat
  // project.ready.then(() => sheet.sequence.play({ iterationCount: Infinity }));
  // Create a sheet
  const sheet = project.sheet("Animated scene");

  const cameraObj = sheet.object("camera", {
    position: types.compound({
      x: types.number(camera.position.x),
      y: types.number(camera.position.y),
      z: types.number(camera.position.z),
    }),
    lookAt: types.compound({
      x: types.number(0),
      y: types.number(0),
      z: types.number(0),
    }),
  });

  cameraObj.onValuesChange((values) => {
    const { position, lookAt } = values;

    camera.position.set(position.x, position.y, position.z);
    camera.lookAt(lookAt.x, lookAt.y, lookAt.z);
  });

  const sceneObj = sheet.object("scene", {
    backgroundColor: types.rgba({ r: 0, g: 0, b: 0, a: 1 }),
  });

  const color = new Color("#000");
  sceneObj.onValuesChange((values) => {
    const { backgroundColor } = values;
    color.set(backgroundColor.toString());
    (scene.background as Color).copy(color);
  });

  data.forEach((item, i) => {
    textureLoader.load(item.src, (text) => {
      const aspect = text.width / text.height;
      const planeGeometry = new PlaneGeometry(item.size * aspect, item.size);
      const planeShaderMaterial = new ShaderMaterial({
        transparent: true,
        uniforms: {
          uMap: {
            value: text,
          },
          uAlphaMap: {
            value: item.alphaMap,
          },
          uSize: {
            value: new Vector2(text.width, text.height),
          },
          uIntensity: {
            value: 1,
          },
        },
        vertexShader: VertexShader,
        fragmentShader: FragmentShader,
      });
      const plane = new Mesh(planeGeometry, planeShaderMaterial);
      plane.position.set(item.position[0], item.position[1], item.position[2]);
      scene.add(plane);

      const planeObj = sheet.object(`plane-${i + 1}`, {
        uIntensity: types.number(1, { range: [0, 1] }),
      });
      planeObj.onValuesChange((value) => {
        planeShaderMaterial.uniforms.uIntensity.value = value.uIntensity;
      });

      renderer.render(scene, camera);
    });
  });

  const ffmpeg = new FFmpeg();
  const baseURL = "https://unpkg.com/@ffmpeg/core-mt@0.12.6/dist/esm";

  ffmpeg.on("log", ({ message }) => {
    console.log(message);
  });
  ffmpeg.on("progress", ({ progress, time }) => {
    console.log("progress: ", progress, time);
  });

  await ffmpeg.load({
    coreURL: await toBlobURL(`${baseURL}/ffmpeg-core.js`, "text/javascript"),
    wasmURL: await toBlobURL(`${baseURL}/ffmpeg-core.wasm`, "application/wasm"),
    workerURL: await toBlobURL(
      `${baseURL}/ffmpeg-core.worker.js`,
      "text/javascript"
    ),
  });

  function captureScreenshot(
    canvas: HTMLCanvasElement,
    fileName: string
  ): Promise<File> {
    return new Promise((resolve) => {
      canvas.toBlob((blob) => {
        const file = new File([blob!], fileName, { type: "image/jpeg" });
        resolve(file);
      }, "image/jpeg");
    });
  }

  async function videoExport(
    frames: File[],
    fileName: string,
    framerate: number
  ) {
    try {
      for (let i = 0; i < frames.length; i++) {
        const file = frames[i];
        const name = `${file.name}.${file.type.replace("image/", "")}`;
        await ffmpeg.writeFile(name, await fetchFile(file));
      }

      const folder = await ffmpeg.listDir("./");
      console.log("folder data", folder);

      const framePattern = `frame%0${String(frames.length).length}d.jpeg`;

      await ffmpeg
        .exec([
          "-framerate",
          String(framerate),
          "-i",
          framePattern,
          "-c:v",
          "libx264",
          "-an",
          "-movflags",
          "faststart",
          "-pix_fmt",
          "yuv420p",
          `${fileName}.mp4`,
        ])
        .catch((err) => {
          if (err.name === "AbortError") {
            console.log(err.message);
          }
        });

      //
      if (!ffmpeg.loaded) return;

      const data = await ffmpeg.readFile(`${fileName}.mp4`);

      for (let i = 0; i < frames.length; i++) {
        const file = frames[i];
        const name = `${file.name}.${file.type.replace("image/", "")}`;
        await ffmpeg.deleteFile(name);
      }

      console.log(data);
      const url = URL.createObjectURL(new Blob([data], { type: "video/mp4" }));

      return url;
    } catch (error) {
      console.error(error);

      return "";
    }
  }

  // @ts-ignore
  window.render = async () => {
    let files: File[] = [];
    const fileName = "test";
    const canvas = renderer.domElement;
    const framerate = 120;
    const totalDurationInSeconds = val(sheet.sequence.pointer.length);
    const totalFrames = Math.floor(totalDurationInSeconds * framerate);
    const minNumLegth = String(totalFrames).length;
    console.log(totalDurationInSeconds);
    let currentSnapshotFrame = 0;

    sheet.sequence.position = 0;

    for (let index = 0; index < totalFrames; index++) {
      const timestamp = currentSnapshotFrame / framerate;

      sheet.sequence.position = timestamp;
      console.log(timestamp);
      // await wait();
      files.push(
        await captureScreenshot(
          canvas!,
          `frame${String(currentSnapshotFrame).padStart(minNumLegth, "0")}`
        )
      );
      // renderer.render(scene, camera);
      currentSnapshotFrame++;
    }

    const url = await videoExport(files, fileName, framerate);
    // const url = URL.createObjectURL(files[4]);
    console.log(url);

    const aTag = document.createElement("a");
    aTag.href = url!;
    aTag.setAttribute("download", "test.mp4");
    document.body.append(aTag);
    aTag.click();
    aTag.remove();
  };
};
init();
