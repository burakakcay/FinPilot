const express = require("express");
const cors = require("cors");
const path = require("path");
const dotenv = require("dotenv");
const { GoogleGenAI } = require("@google/genai");

dotenv.config({
	path: path.join(__dirname, ".env"),
});

const app = express();
const port = 3000;

const ai = new GoogleGenAI({
	apiKey: process.env.GEMINI_API_KEY,
});

app.use(cors());
app.use(express.json());

app.get("/", (req, res) => {
	res.json({
		message: "FinPilot AI server çalışıyor.",
	});
});

app.post("/generate-insight", async (req, res) => {
	const { summary } = req.body;

	if (!summary || typeof summary !== "string") {
		return res.status(400).json({
			error: "Geçerli bir finansal özet gönderilmelidir.",
		});
	}

	try {
		const interaction = await ai.interactions.create({
			model: "gemini-3.6-flash",
			input: `
Sen FinPilot isimli kişisel finans karar destek sisteminin asistanısın.

Yatırım tavsiyesi verme.
Kullanıcının finansal durumunu anlamasına yardımcı olan,
kısa, açık ve Türkçe bir değerlendirme sun.
En fazla üç uygulanabilir öneri ver.
Kullanıcının finansal durumunu anlamasına yardımcı olan,
kısa, açık ve Türkçe bir değerlendirme sun.
En fazla üç uygulanabilir öneri ver.
Selamlama yapma ve kendini tanıtma.
Yanıtına doğrudan finansal değerlendirme ile başla.
Gönderilen finansal özetteki sayıları mutlaka kullan.
Markdown işaretleri kullanma.

Finansal özet:
${summary}
  `,
		});

		return res.json({
			text: interaction.output_text || "İçgörü oluşturulamadı.",
		});
	} catch (error) {
		console.error("Gemini hatası:", error);

		return res.status(500).json({
			error: "AI içgörüsü oluşturulurken bir hata oluştu.",
		});
	}
});

app.listen(port, () => {
	console.log(
		`FinPilot AI server http://localhost:${port} adresinde çalışıyor.`,
	);
});
