import { Injectable } from '@nestjs/common';
import { GlucoseService } from '../glucose/glucose.service';
import { Profile } from '../users/profile.entity';
import { User } from '../users/user.entity';

@Injectable()
export class ReportsService {
  constructor(private readonly glucoseService: GlucoseService) {}

  async generateGlucoseReport(user: User, profile?: Profile) {
    const logs = await this.glucoseService.findAllByUser(user);
    if (!logs.length) {
      return {
        totalLogs: 0,
        averageGlucose: 0,
        timeInRangePercent: 0,
        maxGlucose: 0,
        minGlucose: 0,
      };
    }

    const targetLow = profile?.targetGlucoseLow ? Number(profile.targetGlucoseLow) : 70;
    const targetHigh = profile?.targetGlucoseHigh ? Number(profile.targetGlucoseHigh) : 180;

    let sum = 0;
    let inRangeCount = 0;
    let max = Number(logs[0].value);
    let min = Number(logs[0].value);

    for (const log of logs) {
      const val = Number(log.value);
      sum += val;
      if (val >= targetLow && val <= targetHigh) {
        inRangeCount++;
      }
      if (val > max) max = val;
      if (val < min) min = val;
    }

    const averageGlucose = sum / logs.length;
    const timeInRangePercent = (inRangeCount / logs.length) * 100;

    return {
      totalLogs: logs.length,
      averageGlucose: Math.round(averageGlucose),
      timeInRangePercent: Math.round(timeInRangePercent),
      maxGlucose: max,
      minGlucose: min,
    };
  }
}
