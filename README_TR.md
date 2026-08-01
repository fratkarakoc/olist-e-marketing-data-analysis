# Olist E-Ticaret Veri Analizi

[Olist Brazilian E-Commerce Public Dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) üzerinde, **PostgreSQL** (şema tasarımı, SQL tabanlı analiz) ve **Python** (pandas, seaborn, scipy) kullanılarak yapılan uçtan uca bir veri analizi projesi.

Proje; müşteri segmentasyonunu (RFM), kategori bazlı satış performansını ve teslimat gecikmeleri ile müşteri memnuniyeti arasındaki ilişkiyi kapsıyor.

> 📄 Görselleştirmeler ve iş yorumlarıyla birlikte tam analiz anlatısı için **[REPORT.pdf](./REPORT.pdf)** dosyasına bakabilirsiniz.
> Bu README, teknik uygulamaya odaklanır.

---

## Proje Yapısı

```
├── data/
│   └── raw/                              # Ham Olist CSV dosyaları (izlenmiyor, bkz. .gitignore)
├── notebooks/
│   ├── preparation/
│   │   ├── 01_data_preview.ipynb             # Ham veri setine ilk bakış
│   │   ├── 02_products_to_english.ipynb      # Ürün kategori isimlerinin İngilizceye çevrilmesi
│   │   └── 03_load_data_from_postgresql.ipynb # PostgreSQL'den veri çekme, temizleme & birleştirme
│   └── analysis/
│       ├── 01_rfm_analysis.ipynb             # Müşteri segmentasyonu (RFM)
│       ├── 02_categorical_analysis.ipynb     # Kategori bazlı satış ve değerlendirme analizi
│       └── 03_delivery_time_satisfaction_analysis.ipynb  # Teslimat gecikmesi vs. değerlendirme puanı
├── sql/
│   ├── table_preparation/
│   │   ├── 01_create_tables.sql          # Şema tanımı
│   │   └── 02_foreign_keys.sql           # Foreign key kısıtları
│   └── analysis/
│       ├── 01_sales_revenue_analysis.sql       # Bağımsız SQL gelir analizi
│       └── 02_customer_satisfaction_analysis.sql # Bağımsız SQL memnuniyet analizi
├── .env                                  # Veritabanı kimlik bilgileri (izlenmiyor, bkz. .gitignore)
├── .gitignore
├── README.md
├── README_TR.md
└── REPORT.pdf                             # Görselleştirmeli tam analiz raporu
```

## Kullanılan Teknolojiler

- **Veritabanı:** PostgreSQL
- **Python:** pandas, seaborn, scipy, SQLAlchemy (`psycopg2`), python-dotenv
- **Ortam:** Jupyter Notebook
- **Versiyon kontrol:** Git / GitHub

## İş Akışı

Proje iki aşamadan oluşuyor: **veri hazırlığı** (1–7. adımlar) ve **iki paralel analiz kolu** — biri doğrudan SQL'de, diğeri Python'da (8–12. adımlar).

**1. Veri Hazırlığı**
1. Veri setinin `data/raw/` klasörüne indirilmesi
2. `notebooks/preparation/01_data_preview.ipynb` — ham CSV'lere ilk bakış (yapı, satır sayıları, göze çarpan kalite sorunları)
3. `notebooks/preparation/02_products_to_english.ipynb` — `product_category_name` değerlerinin İngilizceye çevrilmesi, küçük düzeltmeler
4. `sql/table_preparation/01_create_tables.sql` — PostgreSQL'de ilişkisel şemanın oluşturulması
5. `sql/table_preparation/02_foreign_keys.sql` — foreign key kısıtlarının eklenmesi
6. CSV dosyalarının (düzeltilmiş haliyle) PostgreSQL tablolarına aktarılması (manuel import, örn. pgAdmin import aracıyla)
7. `notebooks/preparation/03_load_data_from_postgresql.ipynb` — tabloların SQLAlchemy ile çekilmesi, ardından pandas'ta temizlenmesi ve birleştirilmesi (bkz. [Veri Kalitesi Notları](#veri-kalitesi-notları))

**2a. SQL Tabanlı Analiz (bağımsız)**
8. `sql/analysis/01_sales_revenue_analysis.sql` — doğrudan SQL'de yapılan gelir/satış analizi
9. `sql/analysis/02_customer_satisfaction_analysis.sql` — doğrudan SQL'de yapılan memnuniyet analizi

Bu kol, aşağıdaki Python pipeline'ından bağımsızdır — sadece SQL katmanında yapılan filtreleme/join/aggregation yetkinliğini gösterir.

**2b. Python Tabanlı Analiz**
10. `notebooks/analysis/01_rfm_analysis.ipynb` — Recency-Frequency-Monetary müşteri segmentasyonu
11. `notebooks/analysis/02_categorical_analysis.ipynb` — ürün kategorisi performansı ve değerlendirme puanları
12. `notebooks/analysis/03_delivery_time_satisfaction_analysis.ipynb` — teslimat gecikmesi ile değerlendirme puanı arasındaki istatistiksel ilişki

## Kurulum & Tekrarlanabilirlik

1. Repoyu klonlayın ve [Olist veri setini](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) `data/raw/` klasörüne indirin
2. Proje kök dizininde PostgreSQL kimlik bilgilerinizi içeren bir `.env` dosyası oluşturun:
   ```
   DB_HOST=localhost
   DB_PORT=5432
   DB_NAME=olist
   DB_USER=your_user
   DB_PASSWORD=your_password
   ```
3. `sql/table_preparation/01_create_tables.sql` ve `02_foreign_keys.sql` dosyalarını veritabanınıza karşı çalıştırın
4. Ham CSV'leri ilgili tablolara aktarın
5. Python bağımlılıklarını kurun:
   ```
   pip install pandas seaborn scipy sqlalchemy psycopg2-binary python-dotenv jupyter
   ```
6. Notebook'ları sırayla çalıştırın: `notebooks/preparation/` (`01` → `03`), ardından `notebooks/analysis/` (`01` → `03`); isteğe bağlı olarak `sql/analysis/` altındaki SQL scriptlerini doğrudan veritabanına karşı çalıştırabilirsiniz

## Veri Kalitesi Notları

Süreç boyunca tespit edilip ele alınan bazı veri kalitesi sorunları (tam detay raporda):

- **775 eşleşmeyen `order_items` satırı** — sipariş durumuna göre kontrol edildiğinde, rastgele veri kaybından çok belirli sipariş statülerine bağlı olduğu görüldü
- **`order_payments` anomalisi:** tek bir teslim edilmiş siparişe bağlı, ödeme kaydı olmayan 3 satır
- **551 tekrarlayan değerlendirme kaydı** (aynı sipariş için birden fazla review) — en güncel `review_answer_timestamp` tutularak çözüldü
- **`order_payments` fan-out hatası:** `order_payments` tablosunun `order_items`'a öncesinde deduplication yapılmadan join edilmesi, gelir ve ürün sayılarını yaklaşık %3–5 şişirdi. `payment_value`'nun merge öncesi `order_id` bazında aggregate edilmesiyle düzeltildi.
- **942 boş `review_score` değeri**, gelir odaklı dataframe'de bilinçli olarak korundu (sadece review-score'a özel analizlerde çıkarıldı)

## Sınırlamalar

- Kaynak veride `order_reviews` tablosunun primary key'i yok
- Müşterilerin sadece ~%3'ü tekrar satın alım yaptı, bu da frequency-tabanlı ve cohort/retention analizlerinin derinliğini sınırlıyor
- Market basket / association rule analizi kapsam dışı bırakıldı — siparişlerin %99'undan fazlası tek bir ürün kategorisi içeriyor, bu da bu yaklaşımı bu veri seti için bilgilendirici olmaktan çıkarıyor
