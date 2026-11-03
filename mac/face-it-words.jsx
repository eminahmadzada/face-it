// Face It Words. Übersicht desktop widget.
// Shows today's affirmation and gratitude. Click a card for another.
import { React } from 'uebersicht';

const AFF=[
 ['Capable',[
  'I am very capable and clever. I learn fast and I solve hard problems.',
  'My mind is sharp. I see the answer others miss.',
  'I trust my judgement. I earned it through years of hard work.',
  'I can figure out anything I put my mind to.']],
 ['Value',[
  'I bring real value to my colleagues and my employer every single day.',
  'I make my partner\'s life better. I am her calm, her strength and her safe place.',
  'My family is proud of me, and I make them prouder every year.',
  'People are better off after working with me.',
  'My work matters, and the people around me feel it.']],
 ['Confidence',[
  'I walk into every room calm, confident and ready.',
  'Pressure makes me focused, not afraid.',
  'I do not need anyone\'s permission to be great.',
  'I am proud of who I am and who I am becoming.']],
 ['Communication',[
  'I speak clearly and with confidence. People listen when I talk.',
  'I make complex things simple. That is my gift.',
  'I listen deeply, and people feel understood around me.',
  'I say what I think, kindly and directly.']],
 ['Connection',[
  'I enjoy meeting new people, and they enjoy meeting me.',
  'I connect people and ideas. Doors open because of the bridges I build.',
  'I remember people, I follow up, and I keep my relationships warm.',
  'I give before I ask, and my network grows every week.']],
 ['Achievement',[
  'I always achieve what I plan, because I work hard and I do not quit.',
  'When I decide, I deliver.',
  'Every small win today builds the big win I am working for.',
  'Hard work is my edge, and I never run out of it.',
  'Success is my normal. I build it one day at a time.']]
];
const GRAT=[
 ['If you are grateful, I will surely give you more.','Quran 14:7'],
 ['So remember Me, I will remember you. Be grateful to Me and do not deny Me.','Quran 2:152'],
 ['So which of the favours of your Lord would you deny?','Quran 55:13'],
 ['If you tried to count the blessings of Allah, you could never number them.','Quran 14:34'],
 ['Whoever is grateful, is grateful for the good of his own soul.','Quran 31:12'],
 ['My Lord, enable me to be grateful for the favour You have given me and my parents, and to do good that pleases You.','Quran 27:19'],
 ['Indeed, with hardship comes ease.','Quran 94:6'],
 ['A person will have nothing except what he strives for.','Quran 53:39'],
 ['Allah does not change the condition of a people until they change what is in themselves.','Quran 13:11'],
 ['Once you have decided, put your trust in Allah.','Quran 3:159'],
 ['Whoever puts his trust in Allah, He is enough for him.','Quran 65:3'],
 ['Allah does not burden a soul beyond what it can bear.','Quran 2:286'],
 ['We made you into nations and tribes so that you may know one another.','Quran 49:13'],
 ['And speak good words to people.','Quran 2:83'],
 ['Whoever does not thank people has not thanked Allah.','Hadith, Abu Dawud and Tirmidhi'],
 ['How wonderful is the affair of the believer. If good comes to him, he is grateful, and that is good for him. If hardship comes, he is patient, and that is good for him.','Hadith, Sahih Muslim'],
 ['Look at those below you and not at those above you, so you do not belittle the blessings of Allah upon you.','Hadith, Sahih Muslim'],
 ['The strong believer is better and more beloved to Allah than the weak believer. Strive for what benefits you, seek help from Allah, and do not give up.','Hadith, Sahih Muslim'],
 ['Allah loves that when one of you does a job, he does it with excellence.','Hadith, al Bayhaqi'],
 ['The best of people are those most beneficial to people.','Hadith, al Tabarani'],
 ['Your smile in the face of your brother is charity.','Hadith, Tirmidhi'],
 ['Tie your camel, then put your trust in Allah.','Hadith, Tirmidhi'],
 ['Alhamdulillah ala kulli hal. Praise be to Allah in every situation.','Hadith, Ibn Majah']
];
const ALL=AFF.flatMap(x=>x[1]);
const day=()=>Math.floor((new Date().setHours(0,0,0,0)-new Date(2026,0,1))/864e5);
const mod=(i,n)=>((i%n)+n)%n;

export const refreshFrequency = 1000*60*30;
export const initialState = { a:0, g:0 };
export const command = undefined;
export const updateState = (event, prev) => {
  if (event.type === 'NEXT_A') return { ...prev, a: prev.a+1 };
  if (event.type === 'NEXT_G') return { ...prev, g: prev.g+1 };
  return prev;
};

// Position: change top/left/right/bottom to move it.
export const className = `
  top: 40px; right: 40px; width: 360px;
  font-family: -apple-system, "SF Pro Text", sans-serif; color: #E6E8ED;
  -webkit-font-smoothing: antialiased;
`;

const card = { background:'rgba(22,26,32,.92)', border:'1px solid #2A2F37', borderRadius:18, padding:'18px 20px', marginBottom:12, cursor:'pointer', backdropFilter:'blur(20px)' };
const label = { fontSize:11, fontWeight:600, letterSpacing:'.08em', textTransform:'uppercase', color:'#8B949E' };

export const render = (state, dispatch) => {
  const a = ALL[mod(day()+state.a, ALL.length)];
  const g = GRAT[mod(day()+state.g, GRAT.length)];
  return (
    <div>
      <div style={card} onClick={() => dispatch({type:'NEXT_A'})}>
        <div style={{...label, color:'#67DF70'}}>I am</div>
        <div style={{fontSize:19, fontWeight:600, lineHeight:1.35, marginTop:8}}>{a}</div>
      </div>
      <div style={card} onClick={() => dispatch({type:'NEXT_G'})}>
        <div style={label}>Alhamdulillah</div>
        <div style={{fontSize:17, fontWeight:500, lineHeight:1.4, marginTop:8}}>{g[0]}</div>
        <div style={{color:'#67DF70', fontSize:12, fontWeight:600, marginTop:8}}>{g[1]}</div>
      </div>
    </div>
  );
};
