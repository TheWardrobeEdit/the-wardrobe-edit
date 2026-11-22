(async function(){
 const client=window.tweSupabase;const status=document.getElementById('connectionStatus');
 if(!window.tweSupabaseReady){status.textContent='Setup required';document.getElementById('setupNotice').classList.remove('hidden');return;}
 const {data:{session},error}=await client.auth.getSession();if(error||!session){location.replace('login.html');return;}
 document.getElementById('userEmail').textContent=session.user.email||'Your account';
 const {data:profile}=await client.from('profiles').select('display_name').eq('id',session.user.id).maybeSingle();
 if(profile&&profile.display_name)document.getElementById('welcomeName').textContent=profile.display_name;
 status.textContent='Account connected';
 const {count:garmentCount}=await client.from('garments').select('*',{count:'exact',head:true});
 const {count:outfitCount}=await client.from('outfits').select('*',{count:'exact',head:true});
 document.getElementById('garmentCount').textContent=garmentCount??'—';document.getElementById('outfitCount').textContent=outfitCount??'—';
 document.getElementById('logout').addEventListener('click',async()=>{await client.auth.signOut();location.href='index.html';});
})();
