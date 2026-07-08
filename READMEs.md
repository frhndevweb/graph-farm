# 🌱 Graph Farm

<p align="center">

Automatic GitHub Contribution Graph Generator using **GitHub Actions**.

Automatically creates commits to keep your GitHub contribution graph active.

</p>

---

## ✨ Features

- 🚀 10 Independent GitHub Actions
- 🕒 Asia/Jakarta (WIB)
- 📜 Automatic Log Rotation
- 📊 Automatic Statistics
- 📖 Auto Update README
- 🎲 Random Delay
- ⚡ Production Ready
- 🔥 Lightweight

---

## 📊 Live Status

<!-- FARM_STATUS_START -->

Loading...

<!-- FARM_STATUS_END -->

---

## 📁 Project Structure

```text
.
├── .github
│   └── workflows
│       ├── farm1.yml
│       ├── farm2.yml
│       ├── ...
│       └── farm10.yml
│
├── scripts
│   ├── commit.sh
│   ├── logger.sh
│   ├── rotate.sh
│   └── update-readme.sh
│
├── logs
│   ├── farm1.log
│   ├── farm2.log
│   └── archive
│
├── stats
│   ├── farm1.json
│   ├── farm2.json
│   └── ...
│
└── README.md
```

---

## 📜 Logs

Each workflow writes to its own log.

```text
logs/

farm1.log
farm2.log
farm3.log
...
farm10.log
```

After every **1000 commits**, logs are automatically rotated.

```text
logs/archive/

farm1-2.log
farm1-3.log
farm1-4.log
...
```

---

## ⚙️ Workflows

| Workflow | Schedule |
|----------|----------|
| Farm 1 | Every 5 Minutes |
| Farm 2 | Every 5 Minutes |
| Farm 3 | Every 5 Minutes |
| Farm 4 | Every 5 Minutes |
| Farm 5 | Every 5 Minutes |
| Farm 6 | Every 5 Minutes |
| Farm 7 | Every 5 Minutes |
| Farm 8 | Every 5 Minutes |
| Farm 9 | Every 5 Minutes |
| Farm 10 | Every 5 Minutes |

---

## 🌏 Timezone

```
Asia/Jakarta (WIB)
```

---

## 📄 License

MIT License

---

<p align="center">
Made with ❤️ using GitHub Actions
</p>