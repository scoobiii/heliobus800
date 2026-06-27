/**
 * hb800_data_bridge.ts
 * Puxa dados do monitoring agent (Python/Modbus) e injeta no ThermoFlex
 * via window.postMessage para comunicação entre iframes/componentes
 */

export interface HB800Telemetry {
  ts: string;
  bus_voltage_v: number;        // barramento 800VDC
  loop_supply_temp_c: number;   // supply do CDU (alvo: 18-22°C)
  dew_point_c: number;          // dew point local
  dew_point_margin_c: number;   // margem anti-orvalho (mín 3°C)
  pue: number;                  // Power Usage Effectiveness
  cue: number;                  // Carbon Usage Effectiveness (alvo: 0)
  solar_gen_kw: number;         // geração solar atual
  bess_soc_pct: number;         // State of Charge do BESS
  alerts: string[];
}

// Mapeia telemetria HB800 para o formato do ThermoFlex (PowerPlant/DataCenter)
export function mapToThermoFlex(t: HB800Telemetry) {
  return {
    powerOutput: t.solar_gen_kw,
    efficiency: t.pue > 0 ? (1 / t.pue) * 100 : 0,
    plantStatus: t.alerts.length === 0 ? 'Online' : 'Warning',
    activeRackCount: Math.floor(t.solar_gen_kw / 50), // estimativa: 50kW/rack
    chillerSupplyTemp: t.loop_supply_temp_c,
    dewPointMargin: t.dew_point_margin_c,
    busVoltage: t.bus_voltage_v,
    bessSoC: t.bess_soc_pct,
    alerts: t.alerts,
  };
}

// Polling do monitoring agent (porta 8080 local)
export async function fetchHB800Telemetry(): Promise<HB800Telemetry | null> {
  try {
    const r = await fetch('http://localhost:8080/telemetry', { signal: AbortSignal.timeout(3000) });
    if (!r.ok) return null;
    return await r.json();
  } catch {
    // monitoring agent não disponível — retornar dados stub
    return {
      ts: new Date().toISOString(),
      bus_voltage_v: 800,
      loop_supply_temp_c: 20,
      dew_point_c: 22,
      dew_point_margin_c: -2, // ALERTA: abaixo do mínimo de 3°C
      pue: 1.12,
      cue: 0,
      solar_gen_kw: 850,
      bess_soc_pct: 78,
      alerts: ['STUB: monitoring agent offline — dados simulados'],
    };
  }
}

// Hook React para uso no ThermoFlex
export function useHB800Telemetry(intervalMs = 5000) {
  // copiar para o ThermoFlex e usar:
  // const [data, setData] = useState<HB800Telemetry | null>(null);
  // useEffect(() => { const id = setInterval(async () => {
  //   setData(await fetchHB800Telemetry()); }, intervalMs);
  //   return () => clearInterval(id); }, [intervalMs]);
  // return data;
  console.log(`Hook useHB800Telemetry — polling a cada ${intervalMs}ms`);
}
