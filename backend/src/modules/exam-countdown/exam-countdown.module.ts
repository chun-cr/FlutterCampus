import { Module } from '@nestjs/common';
import { ExamCountdownController } from './exam-countdown.controller';
import { ExamCountdownService } from './exam-countdown.service';

@Module({
  controllers: [ExamCountdownController],
  providers: [ExamCountdownService],
})
export class ExamCountdownModule {}
