#!/usr/bin/env python3
"""Generate 4 JSON mock data files for the token-economy demo."""

import json
import uuid
import random
import os
from datetime import datetime, timedelta

random.seed(42)

OUTPUT_DIR = os.path.dirname(os.path.abspath(__file__))

# ── Helpers ──────────────────────────────────────────────────────────────────

def uid():
    return str(uuid.uuid4())

def ts(start="2024-01-01", end="2024-12-31"):
    s = datetime.fromisoformat(start)
    e = datetime.fromisoformat(end)
    delta = e - s
    r = s + timedelta(seconds=random.randint(0, int(delta.total_seconds())))
    return r.strftime("%Y-%m-%dT%H:%M:%SZ")

def pick(lst):
    return random.choice(lst)

def write_json(name, data):
    path = os.path.join(OUTPUT_DIR, name)
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
    size = os.path.getsize(path)
    print(f"  {name}: {len(data)} entries, {size:,} bytes")

# ── Reference data ───────────────────────────────────────────────────────────

FIRST_NAMES_FR = ["Jean", "Pierre", "Marie", "Sophie", "Luc", "Claire", "Antoine", "Camille",
                  "Nicolas", "Isabelle", "François", "Julie", "Thierry", "Nathalie", "Éric",
                  "Valérie", "Christophe", "Céline", "Olivier", "Sandrine", "Laurent", "Aurélie",
                  "Mathieu", "Émilie", "Romain", "Margaux", "Julien", "Léa", "Guillaume", "Manon"]

FIRST_NAMES_EN = ["James", "Mary", "Robert", "Patricia", "John", "Jennifer", "Michael", "Linda",
                  "David", "Elizabeth", "William", "Barbara", "Richard", "Susan", "Joseph", "Jessica",
                  "Thomas", "Sarah", "Charles", "Karen", "Daniel", "Emily", "Matthew", "Ashley",
                  "Anthony", "Megan", "Andrew", "Rachel", "Mark", "Laura"]

FIRST_NAMES_DE = ["Hans", "Anna", "Klaus", "Greta", "Wolfgang", "Sabine", "Dieter", "Monika",
                  "Stefan", "Petra", "Jürgen", "Katrin", "Markus", "Birgit", "Uwe", "Heike",
                  "Florian", "Lena", "Tobias", "Nadine", "Sebastian", "Jana", "Andreas", "Claudia",
                  "Maximilian", "Sophia", "Felix", "Johanna", "Lukas", "Hannah"]

FIRST_NAMES_ES = ["Carlos", "María", "José", "Ana", "Miguel", "Carmen", "Pedro", "Isabel",
                  "Diego", "Elena", "Alejandro", "Lucía", "Fernando", "Paula", "Roberto", "Laura",
                  "Pablo", "Marta", "Sergio", "Raquel", "Javier", "Beatriz", "Álvaro", "Cristina",
                  "Andrés", "Sofía", "Luis", "Rosa", "Manuel", "Teresa"]

LAST_NAMES_FR = ["Dupont", "Martin", "Durand", "Leroy", "Moreau", "Simon", "Laurent", "Lefebvre",
                 "Michel", "Garcia", "Thomas", "Bertrand", "Robert", "Richard", "Petit", "Roux",
                 "David", "Vincent", "Morel", "Fournier"]

LAST_NAMES_EN = ["Smith", "Johnson", "Williams", "Brown", "Jones", "Davis", "Miller", "Wilson",
                 "Moore", "Taylor", "Anderson", "Thomas", "Jackson", "White", "Harris", "Martin",
                 "Thompson", "Robinson", "Clark", "Lewis"]

LAST_NAMES_DE = ["Müller", "Schmidt", "Schneider", "Fischer", "Weber", "Meyer", "Wagner", "Becker",
                 "Schulz", "Hoffmann", "Koch", "Richter", "Wolf", "Klein", "Schröder", "Neumann",
                 "Schwarz", "Zimmermann", "Braun", "Hartmann"]

LAST_NAMES_ES = ["García", "Rodríguez", "Martínez", "López", "González", "Hernández", "Pérez",
                 "Sánchez", "Ramírez", "Torres", "Flores", "Rivera", "Gómez", "Díaz", "Reyes",
                 "Cruz", "Morales", "Ortiz", "Gutiérrez", "Chávez"]

COUNTRIES_NAMES = {
    "France": (FIRST_NAMES_FR, LAST_NAMES_FR),
    "USA": (FIRST_NAMES_EN, LAST_NAMES_EN),
    "UK": (FIRST_NAMES_EN, LAST_NAMES_EN),
    "Canada": (FIRST_NAMES_EN + FIRST_NAMES_FR, LAST_NAMES_EN + LAST_NAMES_FR),
    "Germany": (FIRST_NAMES_DE, LAST_NAMES_DE),
    "Spain": (FIRST_NAMES_ES, LAST_NAMES_ES),
}

DEPARTMENTS = ["Engineering", "Marketing", "Sales", "HR", "Finance", "Support", "Product"]

CATEGORIES = {
    "Electronics": [
        ("Wireless Bluetooth Headphones", "Premium over-ear headphones with active noise cancellation and 30-hour battery life"),
        ("USB-C Charging Hub", "7-port USB-C hub with 100W power delivery and 4K HDMI output"),
        ("Mechanical Keyboard", "RGB mechanical keyboard with Cherry MX Blue switches and aluminum frame"),
        ("27-inch 4K Monitor", "IPS panel with 99% sRGB coverage and adjustable ergonomic stand"),
        ("Portable SSD 1TB", "NVMe external SSD with USB 3.2 Gen 2 for ultra-fast file transfers"),
        ("Smart Home Speaker", "Voice-controlled speaker with multi-room audio and smart home integration"),
        ("Wireless Mouse", "Ergonomic wireless mouse with 16000 DPI sensor and silent clicks"),
        ("Webcam 1080p", "Full HD webcam with auto-focus, built-in microphone, and privacy shutter"),
        ("Noise Cancelling Earbuds", "True wireless earbuds with ANC and transparency mode"),
        ("Laptop Stand", "Adjustable aluminum laptop stand with ventilation for heat dissipation"),
        ("USB Microphone", "Condenser USB microphone with cardioid pattern for podcasting and streaming"),
        ("Smart Watch", "Fitness tracking smartwatch with GPS, heart rate monitor, and 7-day battery"),
        ("Portable Charger 20000mAh", "High-capacity power bank with USB-C PD and dual USB-A ports"),
        ("Wireless Charging Pad", "Qi-certified 15W fast wireless charging pad with LED indicator"),
        ("Digital Drawing Tablet", "Pressure-sensitive graphics tablet with 8192 levels for digital art"),
        ("Gaming Headset", "7.1 surround sound gaming headset with retractable microphone"),
        ("Action Camera", "Waterproof 4K action camera with image stabilization and wide-angle lens"),
        ("E-Reader", "6.8-inch e-ink display reader with adjustable warm light and 32GB storage"),
        ("Robot Vacuum", "Smart robot vacuum with LiDAR navigation and automatic emptying station"),
        ("Streaming Device", "4K HDR streaming stick with voice remote and all major apps"),
    ],
    "Books": [
        ("Clean Code Handbook", "A comprehensive guide to writing readable, maintainable, and efficient code"),
        ("Data Structures Illustrated", "Visual approach to understanding fundamental data structures and algorithms"),
        ("The Pragmatic Programmer", "Timeless lessons on software craftsmanship and practical development"),
        ("Domain-Driven Design Guide", "Strategic and tactical patterns for complex software modeling"),
        ("Microservices Patterns", "Design patterns and best practices for building microservice architectures"),
        ("System Design Interview", "Comprehensive preparation guide for system design technical interviews"),
        ("Learning Python", "Beginner-friendly introduction to Python programming with hands-on exercises"),
        ("JavaScript: The Good Parts", "Essential guide to the most reliable features of JavaScript"),
        ("The Art of War", "Ancient Chinese military treatise with modern leadership applications"),
        ("Refactoring", "Improving the design of existing code through systematic transformations"),
        ("Designing Data-Intensive Apps", "Architecture patterns for reliable and scalable data systems"),
        ("Kubernetes in Action", "Practical guide to deploying and managing containerized applications"),
        ("The Phoenix Project", "A novel about IT, DevOps, and helping your business win"),
        ("Atomic Habits", "Proven framework for building good habits and breaking bad ones"),
        ("Algorithms to Live By", "Computer science concepts applied to everyday human decisions"),
        ("Head First Design Patterns", "Brain-friendly guide to software design patterns with visual learning"),
        ("Effective Java", "Best practices and idioms for writing high-quality Java programs"),
        ("Staff Engineer", "Leadership beyond the management track in software engineering"),
        ("The Lean Startup", "How today's entrepreneurs use continuous innovation to build businesses"),
        ("Site Reliability Engineering", "How Google runs production systems with reliability at scale"),
    ],
    "Clothing": [
        ("Cotton Crew Neck T-Shirt", "100% organic cotton t-shirt with reinforced shoulder seams"),
        ("Slim Fit Chino Pants", "Stretch cotton chinos with tapered leg and hidden flex waistband"),
        ("Waterproof Hiking Jacket", "Breathable three-layer waterproof jacket with sealed seams"),
        ("Merino Wool Sweater", "Fine-gauge merino wool crewneck sweater with ribbed cuffs"),
        ("Running Shorts", "Lightweight moisture-wicking running shorts with built-in brief"),
        ("Denim Jacket", "Classic medium-wash denim jacket with brass button closure"),
        ("Lightweight Down Vest", "Packable 700-fill down vest with water-resistant shell"),
        ("Linen Button-Down Shirt", "Relaxed-fit linen shirt perfect for warm weather layering"),
        ("Yoga Leggings", "High-waist compression leggings with hidden pocket and four-way stretch"),
        ("Wool Overcoat", "Tailored double-breasted overcoat in Italian wool blend"),
        ("Quick-Dry Polo Shirt", "Performance polo with UPF 50 sun protection and moisture management"),
        ("Fleece Pullover", "Mid-weight recycled fleece pullover with quarter-zip neck"),
        ("Cargo Jogger Pants", "Stretch twill joggers with cargo pockets and elastic cuffs"),
        ("Rain Boots", "Waterproof natural rubber boots with cushioned insole"),
        ("Cashmere Scarf", "Luxuriously soft pure cashmere scarf with fringe detail"),
        ("Athletic Socks 6-Pack", "Cushioned performance socks with arch support and moisture control"),
        ("Leather Belt", "Full-grain Italian leather belt with brushed nickel buckle"),
        ("Insulated Winter Gloves", "Touchscreen-compatible insulated gloves with fleece lining"),
        ("Swim Trunks", "Quick-dry board shorts with mesh lining and side pockets"),
        ("Formal Dress Shirt", "Non-iron cotton dress shirt with spread collar and French cuffs"),
    ],
    "Home": [
        ("Ceramic Coffee Mug Set", "Set of 4 handcrafted ceramic mugs with matte glaze finish"),
        ("Memory Foam Pillow", "Contour memory foam pillow with cooling gel layer and bamboo cover"),
        ("Cast Iron Skillet 12-inch", "Pre-seasoned cast iron skillet with heat-resistant handle"),
        ("LED Desk Lamp", "Adjustable LED desk lamp with wireless charging base and color temperature control"),
        ("Stainless Steel Water Bottle", "Double-wall vacuum insulated bottle keeping drinks cold 24hrs or hot 12hrs"),
        ("Bamboo Cutting Board Set", "Set of 3 organic bamboo cutting boards with juice grooves"),
        ("Scented Soy Candle", "Hand-poured soy wax candle with essential oils and 60-hour burn time"),
        ("Throw Blanket", "Ultra-soft microfiber throw blanket with sherpa lining"),
        ("Indoor Plant Pot Set", "Set of 3 minimalist ceramic planters with bamboo saucers"),
        ("French Press Coffee Maker", "Borosilicate glass French press with stainless steel frame"),
        ("Kitchen Scale", "Digital kitchen scale with tare function and precision to 1g"),
        ("Wall Clock", "Silent quartz wall clock with minimalist Scandinavian design"),
        ("Shower Curtain", "Mildew-resistant polyester shower curtain with modern geometric pattern"),
        ("Storage Basket Set", "Handwoven seagrass baskets with handles for organizing"),
        ("Essential Oil Diffuser", "Ultrasonic aromatherapy diffuser with color-changing LED and timer"),
        ("Non-Stick Bakeware Set", "5-piece carbon steel bakeware set with silicone grips"),
        ("Turkish Bath Towel Set", "Set of 4 quick-dry Turkish cotton towels with hanging loops"),
        ("Knife Block Set", "8-piece German steel knife set with natural acacia wood block"),
        ("Air Purifier", "HEPA air purifier covering up to 500 sq ft with quiet sleep mode"),
        ("Picture Frame Set", "Gallery wall set of 7 frames in mixed sizes with templates"),
    ],
    "Sports": [
        ("Yoga Mat Premium", "Extra-thick 6mm non-slip TPE yoga mat with alignment guides"),
        ("Resistance Band Set", "5-level latex resistance bands with handles and door anchor"),
        ("Adjustable Dumbbells", "Quick-change adjustable dumbbells from 5 to 52.5 lbs per hand"),
        ("Jump Rope", "Speed jump rope with ball bearings and adjustable steel cable"),
        ("Foam Roller", "High-density EVA foam roller for deep tissue massage and recovery"),
        ("Running Shoes", "Lightweight cushioned running shoes with responsive foam midsole"),
        ("Tennis Racket", "Graphite composite tennis racket with vibration dampening technology"),
        ("Cycling Jersey", "Moisture-wicking cycling jersey with rear pockets and reflective elements"),
        ("Boxing Gloves", "12oz synthetic leather boxing gloves with wrist support"),
        ("Swimming Goggles", "Anti-fog UV protection swim goggles with adjustable nose bridge"),
        ("Basketball", "Official size indoor/outdoor composite leather basketball"),
        ("Soccer Ball", "FIFA-approved match ball with thermal bonding construction"),
        ("Hiking Backpack 40L", "Ventilated back panel hiking pack with rain cover and hydration sleeve"),
        ("Camping Hammock", "Lightweight parachute nylon hammock with tree straps rated to 400lbs"),
        ("Fitness Tracker Band", "Water-resistant fitness band with step counter and sleep tracking"),
        ("Pull-Up Bar", "Doorway pull-up bar with multiple grip positions and padding"),
        ("Badminton Set", "Complete badminton set with 4 rackets, net, and shuttlecocks"),
        ("Ski Goggles", "Dual-layer anti-fog ski goggles with OTG design for glasses wearers"),
        ("Climbing Chalk Bag", "Drawstring chalk bag with fleece lining and belt loop"),
        ("Table Tennis Set", "Retractable table tennis net with 4 paddles and 6 balls"),
    ],
    "Food": [
        ("Organic Green Tea Collection", "Assorted box of 60 organic green tea bags from Japanese gardens"),
        ("Dark Chocolate Assortment", "Selection of 24 premium dark chocolates from 70% to 90% cacao"),
        ("Extra Virgin Olive Oil", "Cold-pressed extra virgin olive oil from Andalusian olive groves"),
        ("Artisan Coffee Beans", "Single-origin Ethiopian Yirgacheffe medium roast whole beans 1kg"),
        ("Manuka Honey", "UMF 15+ New Zealand Manuka honey in raw unfiltered form"),
        ("Mixed Nuts Premium", "Roasted and salted premium mix of cashews, almonds, pecans, and macadamias"),
        ("Aged Balsamic Vinegar", "12-year aged traditional balsamic vinegar from Modena"),
        ("Protein Bar Variety Pack", "24-count box of high-protein low-sugar bars in assorted flavors"),
        ("Japanese Rice", "Premium short-grain Koshihikari rice from Niigata prefecture"),
        ("Truffle Salt", "French black truffle infused Fleur de Sel from Camargue"),
        ("Organic Pasta Set", "Artisan bronze-die extruded pasta in 6 classic Italian shapes"),
        ("Spice Collection Box", "20 organic single-origin spices in glass jars with wooden rack"),
        ("Matcha Powder", "Ceremonial grade stone-ground matcha from Uji, Kyoto"),
        ("Dried Fruit Medley", "Sun-dried organic fruit mix: mango, pineapple, cranberry, and apricot"),
        ("Hot Sauce Trio", "Set of 3 small-batch hot sauces ranging from mild to extra hot"),
        ("Sourdough Starter Kit", "Live sourdough starter with flour, guide, and proofing basket"),
        ("Smoked Salmon", "Wild-caught Alaskan sockeye salmon cold-smoked over alder wood"),
        ("Granola", "Crunchy handmade granola with oats, honey, coconut, and dark chocolate"),
        ("Herbal Tea Sampler", "48 individually wrapped herbal tea bags in 12 caffeine-free varieties"),
        ("Sea Salt Caramels", "Hand-dipped caramels with Brittany sea salt in a gift tin"),
    ],
    "Toys": [
        ("Building Block Set 1000pc", "Classic interlocking building blocks in 15 colors with baseplate"),
        ("Remote Control Car", "1:16 scale off-road RC car with 2.4GHz remote and rechargeable battery"),
        ("Science Experiment Kit", "50 experiments covering chemistry, physics, and biology for ages 8+"),
        ("Wooden Train Set", "60-piece wooden railway set with bridges, tunnels, and stations"),
        ("Puzzle 1000 Pieces", "Premium jigsaw puzzle featuring world landmarks with poster guide"),
        ("Board Game Strategy", "Award-winning civilization-building board game for 2-4 players"),
        ("Stuffed Animal Bear", "Ultra-soft plush teddy bear handmade with recycled polyester"),
        ("Art Supply Kit", "150-piece art set with colored pencils, markers, pastels, and sketchpad"),
        ("Drone Mini", "Beginner-friendly mini drone with altitude hold and one-key takeoff"),
        ("Magnetic Tiles Set", "100-piece magnetic building tiles with translucent colors"),
        ("Dollhouse Wooden", "Three-story wooden dollhouse with 15 furniture pieces"),
        ("Telescope Starter", "70mm refractor telescope with tripod and star map for beginners"),
        ("Card Game Collection", "Set of 5 popular family card games in a travel-friendly box"),
        ("Kinetic Sand Kit", "2 lbs of kinetic sand with molds, tools, and play tray"),
        ("Robot Building Kit", "Programmable robot kit with sensors and block-based coding"),
        ("Outdoor Explorer Set", "Kids nature kit with binoculars, compass, magnifying glass, and field guide"),
        ("Musical Instrument Set", "Toddler music set with xylophone, tambourine, maracas, and recorder"),
        ("Marble Run Deluxe", "150-piece marble run construction set with spiral towers and jumps"),
        ("Magic Trick Set", "Professional magic kit with 75 tricks and instructional video access"),
        ("Dinosaur Figure Set", "12 detailed hand-painted dinosaur figures with fact cards"),
    ],
}

SUPPLIERS = [
    "TechVision Industries", "GlobalSource Trading", "PrimeWare Solutions",
    "NexGen Supply Co.", "EcoFirst Distributors", "Atlantic Commerce Group",
    "Pacific Rim Imports", "Continental Goods Ltd.", "Summit Manufacturing",
    "Pinnacle Distribution", "Harbor Logistics Inc.", "Vanguard Wholesale",
    "Alpine Supply Chain", "Meridian Trading Co.", "Horizon Enterprises"
]

TAGS_BY_CATEGORY = {
    "Electronics": ["tech", "gadget", "wireless", "smart", "portable", "USB", "bluetooth", "digital"],
    "Books": ["education", "programming", "career", "non-fiction", "reference", "bestseller", "learning"],
    "Clothing": ["fashion", "casual", "outdoor", "premium", "cotton", "sustainable", "comfortable"],
    "Home": ["kitchen", "decor", "organization", "eco-friendly", "modern", "minimalist", "gift"],
    "Sports": ["fitness", "outdoor", "training", "equipment", "performance", "recovery", "exercise"],
    "Food": ["organic", "gourmet", "artisan", "imported", "natural", "premium", "gift-set"],
    "Toys": ["educational", "creative", "ages-6+", "family", "STEM", "outdoor-play", "gift"],
}

STREETS = {
    "France": ["12 Rue de la Paix", "45 Avenue des Champs-Élysées", "8 Boulevard Saint-Germain",
               "23 Rue du Faubourg Saint-Honoré", "67 Avenue Montaigne", "3 Place Vendôme",
               "15 Rue de Rivoli", "91 Boulevard Haussmann", "44 Rue Saint-Dominique", "7 Quai Voltaire"],
    "USA": ["742 Evergreen Terrace", "123 Main Street", "456 Oak Avenue", "789 Maple Drive",
            "321 Elm Boulevard", "555 Pine Road", "1024 Binary Lane", "2048 Silicon Way",
            "100 Broadway", "250 Park Avenue South"],
    "UK": ["221B Baker Street", "10 Downing Mews", "45 King's Road", "73 Abbey Lane",
           "8 Kensington Gardens", "32 Notting Hill Gate", "14 Portobello Road",
           "56 Camden High Street", "29 Oxford Street", "88 Regent Place"],
    "Germany": ["15 Friedrichstraße", "42 Kurfürstendamm", "8 Unter den Linden",
                "23 Marienplatz", "67 Königstraße", "3 Schillerstraße",
                "51 Goethestraße", "19 Beethovenstraße", "77 Mozartweg", "5 Bachgasse"],
    "Spain": ["25 Gran Vía", "14 Paseo de la Castellana", "8 Calle Mayor", "42 Rambla de Catalunya",
              "71 Avenida de la Constitución", "3 Plaza Mayor", "19 Calle Serrano",
              "55 Paseo del Prado", "33 Calle de Alcalá", "88 Avenida Diagonal"],
    "Canada": ["100 Yonge Street", "55 Rue Sainte-Catherine", "200 Robson Street",
               "75 Jasper Avenue", "30 Sparks Street", "88 Portage Avenue",
               "12 Rue Saint-Jean", "45 Water Street", "67 Spring Garden Road", "22 Whyte Avenue"],
}

CITIES = {
    "France": [("Paris", "75001"), ("Lyon", "69001"), ("Marseille", "13001"),
               ("Toulouse", "31000"), ("Bordeaux", "33000"), ("Nantes", "44000")],
    "USA": [("New York", "10001"), ("San Francisco", "94102"), ("Chicago", "60601"),
            ("Austin", "73301"), ("Seattle", "98101"), ("Boston", "02101")],
    "UK": [("London", "EC1A 1BB"), ("Manchester", "M1 1AE"), ("Edinburgh", "EH1 1YZ"),
           ("Bristol", "BS1 1AA"), ("Birmingham", "B1 1AA"), ("Cambridge", "CB1 1PT")],
    "Germany": [("Berlin", "10115"), ("Munich", "80331"), ("Hamburg", "20095"),
                ("Frankfurt", "60311"), ("Stuttgart", "70173"), ("Cologne", "50667")],
    "Spain": [("Madrid", "28001"), ("Barcelona", "08001"), ("Valencia", "46001"),
              ("Seville", "41001"), ("Bilbao", "48001"), ("Málaga", "29001")],
    "Canada": [("Toronto", "M5H 2N2"), ("Montreal", "H2X 1Y4"), ("Vancouver", "V6B 1A1"),
               ("Ottawa", "K1A 0A6"), ("Calgary", "T2P 1J9"), ("Quebec City", "G1R 4P5")],
}

BROWSERS = ["Chrome/121.0", "Firefox/122.0", "Safari/17.3", "Edge/121.0", "Chrome/120.0",
            "Firefox/121.0", "Safari/17.2", "Chrome/119.0", "Opera/106.0", "Brave/1.62"]
OS_LIST = ["Windows 11", "macOS 14.3", "Ubuntu 22.04", "Windows 10", "macOS 13.6",
           "Fedora 39", "ChromeOS 120", "iOS 17.3", "Android 14", "iPadOS 17.3"]
SEARCH_QUERIES = [
    "wireless headphones", "running shoes size 10", "java programming book",
    "kitchen knife set", "organic coffee beans", "laptop stand adjustable",
    "yoga mat thick", "birthday gift ideas", "usb-c hub", "waterproof jacket",
    "mechanical keyboard", "protein bars", "desk lamp LED", "camping equipment",
    "board games family", "noise cancelling earbuds", "smart home speaker",
    "winter gloves touchscreen", "science kit kids", "french press coffee",
    "monitor 4k 27", "resistance bands set", "olive oil premium",
    "building blocks", "merino wool sweater", "action camera waterproof",
    "cast iron skillet", "puzzle 1000 pieces", "drone beginner",
    "chocolate gift box", "hiking backpack", "bluetooth mouse",
    "sourdough starter", "tennis racket graphite", "throw blanket soft",
]

PAYMENT_METHODS = ["CREDIT_CARD", "DEBIT_CARD", "PAYPAL", "BANK_TRANSFER"]
ORDER_STATUSES = ["PENDING", "CONFIRMED", "SHIPPED", "DELIVERED", "CANCELLED"]
EVENT_TYPES = ["USER_LOGIN", "USER_LOGOUT", "ORDER_CREATED", "ORDER_UPDATED",
               "PAYMENT_PROCESSED", "PRODUCT_VIEWED", "CART_UPDATED", "SEARCH_PERFORMED"]

# ── 1. USERS ─────────────────────────────────────────────────────────────────

def generate_users(n=200):
    users = []
    roles = ["USER"] * 160 + ["ADMIN"] * 20 + ["MANAGER"] * 20
    random.shuffle(roles)
    countries = list(COUNTRIES_NAMES.keys())

    for i in range(n):
        country = pick(countries)
        firsts, lasts = COUNTRIES_NAMES[country]
        first = pick(firsts)
        last = pick(lasts)
        username = f"{first.lower().replace('é','e').replace('ü','u').replace('á','a').replace('ö','o')}.{last.lower().replace('é','e').replace('ü','u').replace('á','a').replace('ö','o')}{random.randint(1,99)}"
        email = f"{username}@{'company' if random.random() < 0.5 else pick(['gmail', 'outlook', 'yahoo', 'proton'])}.com"
        users.append({
            "id": uid(),
            "username": username,
            "email": email,
            "firstName": first,
            "lastName": last,
            "role": roles[i] if i < len(roles) else "USER",
            "active": random.random() < 0.85,
            "createdAt": ts("2023-01-01", "2024-06-30"),
            "department": pick(DEPARTMENTS),
            "country": country,
        })
    return users

# ── 2. PRODUCTS ──────────────────────────────────────────────────────────────

def generate_products():
    products = []
    price_ranges = {
        "Electronics": (19.99, 2499.99),
        "Books": (9.99, 59.99),
        "Clothing": (14.99, 399.99),
        "Home": (7.99, 299.99),
        "Sports": (9.99, 499.99),
        "Food": (4.99, 89.99),
        "Toys": (8.99, 199.99),
    }
    for category, items in CATEGORIES.items():
        lo, hi = price_ranges[category]
        for name, desc in items:
            stock = random.randint(0, 500)
            tags = random.sample(TAGS_BY_CATEGORY[category], k=random.randint(2, 4))
            products.append({
                "id": uid(),
                "name": name,
                "description": desc,
                "category": category,
                "price": round(random.uniform(lo, hi), 2),
                "stock": stock,
                "available": stock > 0,
                "tags": tags,
                "supplier": pick(SUPPLIERS),
                "rating": round(random.uniform(2.5, 5.0), 1),
            })
    random.shuffle(products)
    # Pad to exactly 150 by duplicating with new IDs and slight price variation
    while len(products) < 150:
        base = random.choice(products[:len(CATEGORIES) * 20])
        variant = dict(base)
        variant["id"] = uid()
        variant["name"] = base["name"] + " — Limited Edition"
        variant["price"] = round(base["price"] * random.uniform(0.9, 1.15), 2)
        variant["stock"] = random.randint(0, 100)
        variant["available"] = variant["stock"] > 0
        products.append(variant)
    return products[:150]

# ── 3. ORDERS ────────────────────────────────────────────────────────────────

def generate_orders(users, products, n=300):
    orders = []
    product_ids = [p["id"] for p in products]
    product_prices = {p["id"]: p["price"] for p in products}
    user_countries = {u["id"]: u["country"] for u in users}
    user_ids = [u["id"] for u in users]

    status_weights = [0.15, 0.25, 0.20, 0.30, 0.10]  # PEND, CONF, SHIP, DELIV, CANC

    for _ in range(n):
        user_id = pick(user_ids)
        country = user_countries[user_id]
        num_lines = random.randint(1, 4)
        chosen_products = random.sample(product_ids, k=min(num_lines, len(product_ids)))
        lines = []
        for pid in chosen_products:
            qty = random.randint(1, 5)
            lines.append({
                "productId": pid,
                "quantity": qty,
                "unitPrice": product_prices[pid],
            })

        city, zipcode = pick(CITIES[country])
        street = pick(STREETS[country])

        orders.append({
            "id": uid(),
            "userId": user_id,
            "lines": lines,
            "status": random.choices(ORDER_STATUSES, weights=status_weights, k=1)[0],
            "createdAt": ts(),
            "shippingAddress": {
                "street": street,
                "city": city,
                "zipCode": zipcode,
                "country": country,
            },
            "paymentMethod": pick(PAYMENT_METHODS),
        })
    return orders

# ── 4. EVENTS (the big one) ─────────────────────────────────────────────────

def generate_events(users, products, orders, n=500):
    events = []
    user_ids = [u["id"] for u in users]
    product_data = [(p["id"], p["category"]) for p in products]
    order_data = [(o["id"], sum(l["unitPrice"] * l["quantity"] for l in o["lines"]), len(o["lines"])) for o in orders]

    for _ in range(n):
        event_type = pick(EVENT_TYPES)
        user_id = pick(user_ids)
        session_id = uid()
        ip = f"{random.randint(10,223)}.{random.randint(0,255)}.{random.randint(0,255)}.{random.randint(1,254)}"
        timestamp = ts()

        if event_type == "USER_LOGIN":
            metadata = {
                "browser": pick(BROWSERS),
                "os": pick(OS_LIST),
                "location": {
                    "city": pick(["Paris", "New York", "London", "Berlin", "Madrid", "Toronto",
                                  "San Francisco", "Munich", "Barcelona", "Lyon", "Chicago",
                                  "Montreal", "Hamburg", "Seville", "Vancouver", "Austin",
                                  "Edinburgh", "Toulouse", "Seattle", "Bordeaux"]),
                    "country": pick(list(COUNTRIES_NAMES.keys())),
                    "latitude": round(random.uniform(40.0, 55.0), 6),
                    "longitude": round(random.uniform(-5.0, 15.0), 6),
                },
                "loginMethod": pick(["password", "sso", "oauth2", "mfa"]),
                "deviceType": pick(["desktop", "mobile", "tablet"]),
                "screenResolution": pick(["1920x1080", "2560x1440", "3840x2160", "1366x768", "1440x900"]),
                "userAgent": f"Mozilla/5.0 ({pick(OS_LIST)}) AppleWebKit/537.36 (KHTML, like Gecko) {pick(BROWSERS)}",
                "previousLoginAt": ts("2024-01-01", timestamp[:10]) if random.random() < 0.8 else None,
                "failedAttemptsBeforeSuccess": random.randint(0, 3),
            }
        elif event_type == "USER_LOGOUT":
            metadata = {
                "sessionDuration": random.randint(60, 14400),
                "pagesVisited": random.randint(1, 45),
                "reason": pick(["manual", "timeout", "session_expired", "forced_logout"]),
                "lastPageVisited": pick(["/dashboard", "/products", "/orders", "/profile",
                                         "/settings", "/cart", "/checkout", "/search"]),
                "actionsPerformed": random.randint(0, 120),
                "dataTransferred": f"{round(random.uniform(0.1, 25.5), 2)} MB",
            }
        elif event_type == "ORDER_CREATED":
            oid, total, count = pick(order_data)
            metadata = {
                "orderId": oid,
                "totalAmount": round(total, 2),
                "itemCount": count,
                "currency": "EUR" if random.random() < 0.6 else pick(["USD", "GBP", "CAD"]),
                "couponApplied": random.random() < 0.2,
                "couponCode": f"SAVE{random.randint(5,30)}" if random.random() < 0.2 else None,
                "discountAmount": round(random.uniform(0, total * 0.15), 2) if random.random() < 0.2 else 0,
                "estimatedDelivery": ts(timestamp[:10], "2025-01-31"),
                "shippingMethod": pick(["standard", "express", "next_day", "economy"]),
                "warehouseId": f"WH-{pick(['EU', 'US', 'UK', 'CA'])}-{random.randint(1,5):02d}",
                "priorityLevel": pick(["normal", "high", "rush"]),
            }
        elif event_type == "ORDER_UPDATED":
            oid, total, count = pick(order_data)
            metadata = {
                "orderId": oid,
                "previousStatus": pick(ORDER_STATUSES),
                "newStatus": pick(ORDER_STATUSES),
                "updatedBy": pick(["system", "admin", "customer", "warehouse"]),
                "reason": pick(["status_change", "address_update", "item_modification",
                                "cancellation_request", "payment_confirmed", "shipment_dispatched"]),
                "trackingNumber": f"TRK{random.randint(100000000, 999999999)}" if random.random() < 0.4 else None,
                "carrierName": pick(["DHL", "FedEx", "UPS", "La Poste", "Royal Mail", "DPD", "GLS"]) if random.random() < 0.4 else None,
                "notificationSent": random.random() < 0.7,
                "notificationChannel": pick(["email", "sms", "push", "none"]),
            }
        elif event_type == "PAYMENT_PROCESSED":
            oid, total, _ = pick(order_data)
            method = pick(PAYMENT_METHODS)
            metadata = {
                "orderId": oid,
                "amount": round(total, 2),
                "method": method,
                "transactionId": f"TXN-{uid()[:12].upper()}",
                "currency": pick(["EUR", "USD", "GBP", "CAD"]),
                "status": pick(["success", "success", "success", "pending", "failed"]),
                "processorResponse": pick(["approved", "approved", "declined_insufficient_funds",
                                            "approved", "declined_expired_card", "approved"]),
                "cardLastFour": f"{random.randint(1000,9999)}" if "CARD" in method else None,
                "cardBrand": pick(["Visa", "Mastercard", "Amex"]) if "CARD" in method else None,
                "riskScore": round(random.uniform(0, 100), 1),
                "fraudCheckPassed": random.random() < 0.95,
                "processingTimeMs": random.randint(150, 3500),
                "gatewayName": pick(["Stripe", "Adyen", "PayPal", "Square", "Mollie"]),
                "receiptUrl": f"https://pay.example.com/receipts/{uid()[:8]}",
            }
        elif event_type == "PRODUCT_VIEWED":
            pid, cat = pick(product_data)
            metadata = {
                "productId": pid,
                "category": cat,
                "duration": random.randint(3, 300),
                "referrer": pick(["search", "homepage", "category_page", "recommendation",
                                   "email_campaign", "social_media", "direct", "advertisement"]),
                "addedToCart": random.random() < 0.25,
                "addedToWishlist": random.random() < 0.1,
                "viewedImages": random.randint(0, 8),
                "scrollDepth": random.randint(10, 100),
                "previouslyViewed": random.random() < 0.3,
                "priceAtView": round(random.uniform(5.0, 500.0), 2),
                "availableAtView": random.random() < 0.9,
                "recommendationPosition": random.randint(1, 20) if random.random() < 0.3 else None,
            }
        elif event_type == "SEARCH_PERFORMED":
            results_count = random.randint(0, 350)
            metadata = {
                "query": pick(SEARCH_QUERIES),
                "resultsCount": results_count,
                "filters": {
                    "category": pick(list(CATEGORIES.keys())) if random.random() < 0.5 else None,
                    "priceMin": round(random.uniform(0, 50), 2) if random.random() < 0.3 else None,
                    "priceMax": round(random.uniform(50, 2500), 2) if random.random() < 0.3 else None,
                    "inStockOnly": random.random() < 0.4,
                    "rating": round(random.uniform(3.0, 5.0), 1) if random.random() < 0.3 else None,
                    "sortBy": pick(["relevance", "price_asc", "price_desc", "rating", "newest"]),
                },
                "searchDurationMs": random.randint(15, 850),
                "pageNumber": random.randint(1, 5),
                "resultsPerPage": pick([20, 40, 60]),
                "didClickResult": random.random() < 0.65,
                "clickedResultPosition": random.randint(1, 20) if random.random() < 0.65 else None,
                "suggestionsShown": random.randint(0, 8),
                "spellCorrected": random.random() < 0.1,
                "originalQuery": None,
            }
        elif event_type == "CART_UPDATED":
            pid, cat = pick(product_data)
            action = pick(["add", "add", "add", "remove"])
            metadata = {
                "action": action,
                "productId": pid,
                "quantity": random.randint(1, 3),
                "category": cat,
                "cartTotalBefore": round(random.uniform(0, 500), 2),
                "cartTotalAfter": round(random.uniform(10, 600), 2),
                "cartItemCount": random.randint(1, 12),
                "productPrice": round(random.uniform(5.0, 500.0), 2),
                "source": pick(["product_page", "cart_page", "quick_add", "wishlist", "recommendation"]),
                "isGiftWrapped": random.random() < 0.05,
            }

        events.append({
            "id": uid(),
            "type": event_type,
            "userId": user_id,
            "timestamp": timestamp,
            "metadata": metadata,
            "source": pick(["web", "web", "mobile", "mobile", "api"]),
            "sessionId": session_id,
            "ipAddress": ip,
        })

    # Sort by timestamp for realism
    events.sort(key=lambda e: e["timestamp"])
    return events

# ── Main ─────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Generating mock data...")

    users = generate_users(200)
    write_json("users.json", users)

    products = generate_products()
    write_json("products.json", products)

    orders = generate_orders(users, products, 300)
    write_json("orders.json", orders)

    events = generate_events(users, products, orders, 500)
    write_json("events.json", events)

    print("\nDone! Files written to:", OUTPUT_DIR)
