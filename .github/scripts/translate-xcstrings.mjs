// scripts/translate-xcstrings.mjs
//
// Parses a .xcstrings file, finds untranslated keys,
// translates them using Claude API, and writes them back.
//

import fs from "fs";
import path from "path";

const ANTHROPIC_API_KEY = process.env.ANTHROPIC_API_KEY;
const XCSTRINGS_PATH = process.env.XCSTRINGS_PATH;
const TARGET_LANGUAGES = process.env.TARGET_LANGUAGES?.split(",") || [];
const BATCH_SIZE = 30; // Keys per API call to stay within token limits

if (!ANTHROPIC_API_KEY || !XCSTRINGS_PATH || TARGET_LANGUAGES.length === 0) {
  console.error("❌ Missing required env vars: ANTHROPIC_API_KEY, XCSTRINGS_PATH, TARGET_LANGUAGES");
  process.exit(1);
}

// --- Claude API call ---
async function callClaude(prompt, systemPrompt) {
  const response = await fetch("https://api.anthropic.com/v1/messages", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "x-api-key": ANTHROPIC_API_KEY,
      "anthropic-version": "2023-06-01",
    },
    body: JSON.stringify({
      model: "claude-sonnet-4-20250514",
      max_tokens: 4096,
      system: systemPrompt,
      messages: [{ role: "user", content: prompt }],
    }),
  });

  if (!response.ok) {
    const error = await response.text();
    throw new Error(`Claude API error ${response.status}: ${error}`);
  }

  const data = await response.json();
  return data.content[0].text;
}

// --- Find untranslated keys for a given language ---
function findUntranslatedKeys(strings, sourceLang, targetLang) {
  const untranslated = {};

  for (const [key, value] of Object.entries(strings)) {
    // Skip non-translatable keys
    if (value.shouldTranslate === false) continue;

    const sourceValue =
      value.localizations?.[sourceLang]?.stringUnit?.value || key;

    const targetValue =
      value.localizations?.[targetLang]?.stringUnit?.value;

    // If no translation exists for this language, add it
    if (!targetValue || targetValue === "") {
      untranslated[key] = sourceValue;
    }
  }

  return untranslated;
}

// --- Translate a batch of strings ---
async function translateBatch(strings, sourceLang, targetLang) {
  const langNames = {
    es: "Spanish",
    fr: "French",
    de: "German",
    pt: "Portuguese",
    "pt-BR": "Brazilian Portuguese",
    it: "Italian",
    ja: "Japanese",
    ko: "Korean",
    "zh-Hans": "Simplified Chinese",
    "zh-Hant": "Traditional Chinese",
    ar: "Arabic",
    ru: "Russian",
    nl: "Dutch",
    sv: "Swedish",
    da: "Danish",
    fi: "Finnish",
    no: "Norwegian",
    pl: "Polish",
    tr: "Turkish",
    th: "Thai",
    vi: "Vietnamese",
    id: "Indonesian",
    ms: "Malay",
    hi: "Hindi",
    he: "Hebrew",
    uk: "Ukrainian",
    cs: "Czech",
    ro: "Romanian",
    hu: "Hungarian",
    el: "Greek",
    ca: "Catalan",
  };

  const targetLangName = langNames[targetLang] || targetLang;

  const systemPrompt = `You are a professional translator for a children's story app (ages 3-8) called "Buky". 
The app is set in the "Forest of Dreams" with characters like Luna (a brave rabbit), Nico (a wise owl), Rayo (a speedy fox), and Flora (an artist squirrel).

Rules:
- Translate naturally for the target audience (children and their parents)
- Keep the tone warm, playful, and age-appropriate
- Preserve any placeholders like %@, %d, %lld, or {variable} exactly as they are
- Do NOT translate character names (Luna, Nico, Rayo, Flora)
- Do NOT translate the app name "Buky"
- Respond ONLY with valid JSON, no markdown, no backticks, no explanation`;

  const prompt = `Translate the following strings from ${sourceLang} to ${targetLangName}.

Input JSON (key → source text):
${JSON.stringify(strings, null, 2)}

Return a JSON object with the SAME keys and the translated values.
Example: {"key1": "translated text 1", "key2": "translated text 2"}

ONLY return the JSON object, nothing else.`;

  const result = await callClaude(prompt, systemPrompt);

  // Parse response, cleaning possible markdown fences
  const cleaned = result.replace(/```json\n?|```\n?/g, "").trim();
  return JSON.parse(cleaned);
}

// --- Write translations back to xcstrings ---
function writeTranslations(xcstrings, translations, targetLang) {
  for (const [key, translatedValue] of Object.entries(translations)) {
    if (!xcstrings.strings[key]) continue;

    // Ensure localizations object exists
    if (!xcstrings.strings[key].localizations) {
      xcstrings.strings[key].localizations = {};
    }

    // Write translation
    xcstrings.strings[key].localizations[targetLang] = {
      stringUnit: {
        state: "translated",
        value: translatedValue,
      },
    };
  }

  return xcstrings;
}

// --- Main ---
async function main() {
  console.log(`📖 Reading ${XCSTRINGS_PATH}...`);
  const raw = fs.readFileSync(XCSTRINGS_PATH, "utf-8");
  let xcstrings = JSON.parse(raw);

  const sourceLang = xcstrings.sourceLanguage || "en";
  console.log(`🌍 Source language: ${sourceLang}`);
  console.log(`🎯 Target languages: ${TARGET_LANGUAGES.join(", ")}`);

  let totalTranslated = 0;

  for (const targetLang of TARGET_LANGUAGES) {
    console.log(`\n--- Translating to ${targetLang} ---`);

    // Find what needs translating
    const untranslated = findUntranslatedKeys(
      xcstrings.strings,
      sourceLang,
      targetLang
    );

    const keys = Object.keys(untranslated);
    if (keys.length === 0) {
      console.log(`  ✅ All keys already translated for ${targetLang}`);
      continue;
    }

    console.log(`  📝 ${keys.length} keys need translation`);

    // Process in batches
    for (let i = 0; i < keys.length; i += BATCH_SIZE) {
      const batchKeys = keys.slice(i, i + BATCH_SIZE);
      const batch = {};
      for (const k of batchKeys) {
        batch[k] = untranslated[k];
      }

      const batchNum = Math.floor(i / BATCH_SIZE) + 1;
      const totalBatches = Math.ceil(keys.length / BATCH_SIZE);
      console.log(`  🔄 Batch ${batchNum}/${totalBatches} (${batchKeys.length} keys)...`);

      try {
        const translations = await translateBatch(batch, sourceLang, targetLang);
        xcstrings = writeTranslations(xcstrings, translations, targetLang);
        totalTranslated += Object.keys(translations).length;
        console.log(`  ✅ Batch ${batchNum} complete`);
      } catch (error) {
        console.error(`  ❌ Batch ${batchNum} failed: ${error.message}`);
        // Continue with next batch instead of failing entirely
      }

      // Small delay to avoid rate limits
      if (i + BATCH_SIZE < keys.length) {
        await new Promise((r) => setTimeout(r, 1000));
      }
    }
  }

  // Write updated file
  console.log(`\n💾 Writing updated ${XCSTRINGS_PATH}...`);
  fs.writeFileSync(XCSTRINGS_PATH, JSON.stringify(xcstrings, null, 2) + "\n");

  console.log(`\n🎉 Done! Translated ${totalTranslated} strings total.`);

  // Set output for GitHub Actions
  if (process.env.GITHUB_OUTPUT) {
    fs.appendFileSync(
      process.env.GITHUB_OUTPUT,
      `translated_count=${totalTranslated}\n`
    );
  }
}

main().catch((error) => {
  console.error("❌ Fatal error:", error);
  process.exit(1);
});
