(function(){
  const cfg=window.TWE_CONFIG||{};
  const valid=cfg.supabaseUrl&&cfg.supabaseAnonKey&&!cfg.supabaseUrl.startsWith('YOUR_')&&!cfg.supabaseAnonKey.startsWith('YOUR_');
  window.tweSupabaseReady=Boolean(valid&&window.supabase&&window.supabase.createClient);
  window.tweSupabase=window.tweSupabaseReady?window.supabase.createClient(cfg.supabaseUrl,cfg.supabaseAnonKey,{auth:{persistSession:true,autoRefreshToken:true,detectSessionInUrl:true}}):null;
})();
