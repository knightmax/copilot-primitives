# Le Vrai Coût de l'IA : Tokens, Infra et Impact Carbone (Rapport 2026)

## 1. La réalité du modèle d'abonnement
L'abonnement standard (ex: ChatGPT Plus, Claude Pro, Gemini Advanced) coûte environ **20 $ par mois**. Ce modèle est basé sur un principe de mutualisation : 
- Les utilisateurs "occasionnels" ne consomment que quelques centimes de puissance de calcul par mois.
- Les "power users" (développeurs, chercheurs) peuvent générer pour plus de 50 $à 100$ de requêtes s'ils utilisent des modèles de raisonnement complexes ou de très longs contextes. Pour limiter la casse financière, les fournisseurs imposent des **limites d'utilisation** (ex: X messages toutes les 3 heures).

---

## 2. Exemples concrets (Tarifs et Métriques de 2026)

L'année 2026 a vu l'effondrement des prix de l'API (ex: GPT-5 coûte environ 1,25 $ / 1M tokens en entrée) et l'arrivée des architectures NVIDIA Blackwell, mais le coût énergétique reste bien réel.

### Exemple A : Rédiger un email standard (500 mots)
- **Consommation :** ~1 500 tokens (Prompt + Contexte + Réponse).
- **Prix API (Modèle standard, ex: GPT-4.1 Mini) :** ~0,0006 $
- **Coût d'Infra (Électricité) :** 0,3 à 0,5 Watt-heure (Wh).
- **Émission de CO₂ :** ~0,12 à 0,2 grammes de CO₂e.
- **Comparaison :** Équivaut à faire tourner un réfrigérateur pendant environ 6 secondes.

### Exemple B : Résumer un document financier ou juridique (20 pages)
- **Consommation :** ~15 000 tokens en entrée, ~1 000 tokens en sortie.
- **Prix API (Modèle performant, ex: GPT-5) :** ~0,03 $
- **Coût d'Infra (Électricité) :** ~2,5 à 4 Wh.
- **Émission de CO₂ :** ~1,0 à 2,5 grammes de CO₂e.
- **Comparaison :** Équivaut à recharger un smartphone de 10 à 15 %.

### Exemple C : Génération et débuggage d'un script de code complexe
- **Consommation :** ~8 000 tokens, mais utilisation d'un **modèle de raisonnement** (ex: o4-mini, o3) qui génère des "tokens invisibles" (Chain-of-Thought) augmentant la charge GPU.
- **Prix API (o4-mini) :** ~0,05 $
- **Coût d'Infra (Électricité) :** ~15 à 30 Wh (le modèle "réfléchit" longuement).
- **Émission de CO₂ :** ~4 à 14,5 grammes de CO₂e.
- **Comparaison :** Équivaut à l'empreinte carbone du streaming vidéo (Netflix) pendant 15 minutes.

### Exemple D : Recherche approfondie "Deep Research" / Agent Autonome
- **Consommation :** L'agent navigue, lit, synthétise, générant entre 100 000 et 500 000 tokens au total sur de multiples itérations.
- **Prix API (GPT-5) :** ~1,50 $à 5,00$ *pour une seule mission complexe*.
- **Coût d'Infra (Électricité) :** 150 à 400 Wh (utilisation intensive des clusters GPU Blackwell/Hopper).
- **Émission de CO₂ :** ~20 à 88 grammes de CO₂e (voire plus selon le mix énergétique du datacenter).
- **Comparaison :** Équivaut à conduire une voiture à essence sur 1 à 3 kilomètres.

---

## 3. L'envers du décor : L'Infrastructure
Derrière ces tokens se trouvent des racks de serveurs. En 2026, un serveur équipé de 8 GPU NVIDIA H100 ou B200 consomme jusqu'à **10 à 12 kW**. Bien que l'optimisation algorithmique (quantization, pruning) ait divisé par 10 le coût financier du token depuis 2024, le volume absolu des requêtes mondiales a fait exploser l'empreinte environnementale totale, l'IA contribuant aujourd'hui à hauteur de dizaines de millions de tonnes de CO₂ annuellement.

*Sources : Données marché 2026 (NVIDIA Blackwell Pricing, OpenAI API 2026 Specs), Études environnementales (Earth911, Luccioni et al.).*