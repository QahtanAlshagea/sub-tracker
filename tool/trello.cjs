const fs = require('fs');
const path = require('path');

const configPath = path.join(__dirname, '.trello_config.json');
let config = {};
if (fs.existsSync(configPath)) {
  config = JSON.parse(fs.readFileSync(configPath, 'utf8'));
}

const API_KEY = process.env.TRELLO_API_KEY || config.apiKey;
const API_TOKEN = process.env.TRELLO_API_TOKEN || config.apiToken;
const BOARD_ID = process.env.TRELLO_BOARD_ID || config.boardId;
const USERNAME = process.env.TRELLO_USERNAME || config.username || 'mounthralidrious';

if (!API_KEY || !API_TOKEN || !BOARD_ID) {
  console.error('Error: Missing Trello credentials in tool/.trello_config.json or environment variables.');
  process.exit(1);
}

async function request(apiPath, options = {}) {
  const sep = apiPath.includes('?') ? '&' : '?';
  const url = `https://api.trello.com/1${apiPath}${sep}key=${API_KEY}&token=${API_TOKEN}`;
  const res = await fetch(url, options);
  if (!res.ok) {
    throw new Error(`Trello API error ${res.status}: ${await res.text()}`);
  }
  return res.json();
}

async function getListsAndCards() {
  const lists = await request(`/boards/${BOARD_ID}/lists`);
  const cards = await request(`/boards/${BOARD_ID}/cards?checklists=all&members=true`);
  return { lists, cards };
}

async function main() {
  const [cmd, arg1, arg2] = process.argv.slice(2);

  if (!cmd || cmd === 'summary' || cmd === 'list') {
    const { lists, cards } = await getListsAndCards();
    console.log(`\n=== Sub Tracker Team Board Status ===`);
    for (const l of lists) {
      const listCards = cards.filter(c => c.idList === l.id);
      console.log(`\n[ ${l.name} (${listCards.length}) ]`);
      for (const c of listCards) {
        const members = c.members.map(m => m.fullName).join(', ') || 'Unassigned';
        console.log(`  - ${c.name} [${members}]`);
      }
    }
    return;
  }

  if (cmd === 'my-tasks') {
    const { lists, cards } = await getListsAndCards();
    console.log(`\n=== المهام الموكلة للمهندس محمد العيدروس (@${USERNAME}) ===`);
    const myCards = cards.filter(c => c.members.some(m => m.username === USERNAME));
    for (const c of myCards) {
      const list = lists.find(l => l.id === c.idList);
      console.log(`\n📌 ${c.name} (الحالة: ${list ? list.name : 'Unknown'})`);
      console.log(`   الوصف: ${c.desc.split('\n')[0]}`);
      if (c.checklists) {
        for (const cl of c.checklists) {
          for (const item of cl.checkItems) {
            console.log(`   [${item.state === 'complete' ? '✔' : ' '}] ${item.name}`);
          }
        }
      }
    }
    return;
  }

  if (cmd === 'get') {
    const code = arg1;
    if (!code) {
      console.error('يرجى تحديد رمز المهمة، مثال: node tool/trello.cjs get C-07');
      return;
    }
    const { lists, cards } = await getListsAndCards();
    const card = cards.find(c => c.name.includes(code));
    if (!card) {
      console.error(`المهمة ${code} غير موجودة.`);
      return;
    }
    const list = lists.find(l => l.id === card.idList);
    console.log(`\n========================================`);
    console.log(`العنوان: ${card.name}`);
    console.log(`القائمة: ${list ? list.name : 'Unknown'}`);
    console.log(`المسؤول: ${card.members.map(m => m.fullName).join(', ')}`);
    console.log(`التسميات: ${card.labels.map(l => l.name).join(', ')}`);
    console.log(`الرابط: ${card.shortUrl}`);
    console.log(`\nالوصف:\n${card.desc}`);
    if (card.checklists) {
      console.log(`\nقوائم التحقق:`);
      for (const cl of card.checklists) {
        console.log(`-- ${cl.name} --`);
        for (const item of cl.checkItems) {
          console.log(` [${item.state === 'complete' ? '✔' : ' '}] ${item.name}`);
        }
      }
    }
    console.log(`========================================\n`);
    return;
  }

  if (cmd === 'move') {
    const code = arg1;
    const targetListName = arg2;
    if (!code || !targetListName) {
      console.error('الاستخدام: node tool/trello.cjs move C-07 "In Progress"');
      return;
    }
    const { lists, cards } = await getListsAndCards();
    const card = cards.find(c => c.name.includes(code));
    if (!card) {
      console.error(`المهمة ${code} غير موجودة.`);
      return;
    }
    const targetList = lists.find(l => l.name.toLowerCase().includes(targetListName.toLowerCase()));
    if (!targetList) {
      console.error(`القائمة "${targetListName}" غير موجودة. القوائم المتاحة:\n${lists.map(l => l.name).join(', ')}`);
      return;
    }
    await request(`/cards/${card.id}?idList=${targetList.id}`, { method: 'PUT' });
    console.log(`✅ تم نقل البطاقة "${card.name}" بنجاح إلى "${targetList.name}".`);
    return;
  }

  if (cmd === 'check') {
    const code = arg1;
    const itemKeyword = arg2;
    if (!code || !itemKeyword) {
      console.error('الاستخدام: node tool/trello.cjs check C-07 "Money"');
      return;
    }
    const { cards } = await getListsAndCards();
    const card = cards.find(c => c.name.includes(code));
    if (!card) {
      console.error(`المهمة ${code} غير موجودة.`);
      return;
    }
    let found = false;
    if (card.checklists) {
      for (const cl of card.checklists) {
        for (const item of cl.checkItems) {
          if (item.name.toLowerCase().includes(itemKeyword.toLowerCase())) {
            await request(`/cards/${card.id}/checkItem/${item.id}?state=complete`, { method: 'PUT' });
            console.log(`✅ تم تأكيد بند التحقق: "${item.name}"`);
            found = true;
          }
        }
      }
    }
    if (!found) {
      console.error(`لم يتم العثور على بند يحتوي على: "${itemKeyword}"`);
    }
    return;
  }

  if (cmd === 'comment') {
    const code = arg1;
    const text = arg2;
    if (!code || !text) {
      console.error('الاستخدام: node tool/trello.cjs comment C-07 "تم البدء بالتنفيذ"');
      return;
    }
    const { cards } = await getListsAndCards();
    const card = cards.find(c => c.name.includes(code));
    if (!card) {
      console.error(`المهمة ${code} غير موجودة.`);
      return;
    }
    await request(`/cards/${card.id}/actions/comments?text=${encodeURIComponent(text)}`, { method: 'POST' });
    console.log(`✅ تم نشر التعليق بنجاح على البطاقة "${card.name}".`);
    return;
  }

  console.log(`أوامر أداة Trello المتاحة:
- node tool/trello.cjs list
- node tool/trello.cjs my-tasks
- node tool/trello.cjs get <رمز-المهمة>
- node tool/trello.cjs move <رمز-المهمة> <اسم-القائمة>
- node tool/trello.cjs check <رمز-المهمة> <كلمة-من-البند>
- node tool/trello.cjs comment <رمز-المهمة> "نص التعليق"
`);
}

main().catch(console.error);
