import { Body, Controller, Delete, Get, Param, Post, Put, Req, UseGuards } from '@nestjs/common';
import { Request } from 'express';
import { AuthUser } from '../auth/auth.types';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { CreateExamCountdownDto } from './dto/create-exam-countdown.dto';
import { UpdateExamCountdownDto } from './dto/update-exam-countdown.dto';
import { ExamCountdownService } from './exam-countdown.service';

type AuthedRequest = Request & { user: AuthUser };

@Controller('exam-countdowns')
@UseGuards(JwtAuthGuard)
export class ExamCountdownController {
  constructor(private readonly examCountdownService: ExamCountdownService) {}

  @Get()
  async list(@Req() request: AuthedRequest) {
    return this.examCountdownService.listByUser(request.user.userId);
  }

  @Post()
  async create(
    @Req() request: AuthedRequest,
    @Body() payload: CreateExamCountdownDto,
  ) {
    return this.examCountdownService.create(request.user.userId, payload);
  }

  @Put(':id')
  async update(
    @Req() request: AuthedRequest,
    @Param('id') id: string,
    @Body() payload: UpdateExamCountdownDto,
  ) {
    return this.examCountdownService.update(request.user.userId, id, payload);
  }

  @Delete(':id')
  async remove(@Req() request: AuthedRequest, @Param('id') id: string) {
    await this.examCountdownService.remove(request.user.userId, id);
    return { success: true };
  }
}
